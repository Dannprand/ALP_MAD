//
//  ALP_MADTests.swift
//  ALP-MADTests
//
//  Created by student on 22/05/25.
//
//
import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import ALP_MAD
import CoreLocation

// MARK: - Fake Firestore Components

class FakeListenerRegistration: ListenerRegistration {
    func remove() {
        // Do nothing
    }
}

class FakeDocumentSnapshot: QueryDocumentSnapshot {
    let fakeData: [String: Any]
    let fakeDocumentID: String

    init(id: String, data: [String: Any]) {
        self.fakeData = data
        self.fakeDocumentID = id
        super.init()
    }

    override var documentID: String { fakeDocumentID }

    override func data() -> [String: Any] { fakeData }
}

class FakeQuerySnapshot: QuerySnapshot {
    let fakeChanges: [DocumentChange]

    init(documents: [QueryDocumentSnapshot]) {
        let changes = documents.map {
            DocumentChange(
                document: $0,
                oldIndex: 0,
                newIndex: 0,
                type: .added
            )
        }
        self.fakeChanges = changes
        super.init()
    }

    override var documentChanges: [DocumentChange] {
        return fakeChanges
    }
}

class FakeQuery: Query {
    var snapshotHandler: ((QuerySnapshot?, Error?) -> Void)?

    override func order(by field: String, descending: Bool) -> Query {
        return self
    }

    override func addSnapshotListener(_ listener: @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration {
        self.snapshotHandler = listener
        return FakeListenerRegistration()
    }

    func triggerSnapshot(_ documents: [QueryDocumentSnapshot]) {
        let snapshot = FakeQuerySnapshot(documents: documents)
        snapshotHandler?(snapshot, nil)
    }
}

class FakeCollectionReference: CollectionReference {
    var fakeDocuments: [QueryDocumentSnapshot] = []
    var lastAddedDocument: [String: Any]?

    override func document(_ documentPath: String) -> DocumentReference {
        return FakeDocumentReference()
    }

    override func order(by field: String, descending: Bool) -> Query {
        return FakeQuery()
    }
}

class FakeDocumentReference: DocumentReference {
    override func collection(_ collectionPath: String) -> CollectionReference {
        return FakeCollectionReference()
    }

    override func setData(_ documentData: [String : Any], completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
}

class FakeFirestore: Firestore {
    var fakeCollection = FakeCollectionReference()

    override func collection(_ collectionPath: String) -> CollectionReference {
        return fakeCollection
    }
}

//////////////////////

final class ChatViewModelTests: XCTestCase {

    func testSetupChatAppendsMessages() {
        // Given
        let fakeFirestore = FakeFirestore()
        let viewModel = ChatViewModel(db: fakeFirestore)

        let fakeQuery = FakeQuery()
        let fakeCollection = FakeCollectionReference()
        let fakeDocumentData: [String: Any] = [
            "senderId": "user123",
            "senderName": "Alice",
            "text": "Hello world!",
            "timestamp": Timestamp(date: Date()),
            "eventId": "event_1"
        ]
        let fakeDoc = FakeDocumentSnapshot(id: "msg1", data: fakeDocumentData)

        // Replace query with the one we control
        fakeCollection.fakeDocuments = [fakeDoc]
        let fakeQuerySnapshot = FakeQuerySnapshot(documents: [fakeDoc])

        // When
        viewModel.setupChat(forEvent: "event_1")
        
        // Simulate Firestore sending a snapshot
        let query = viewModel.value(forKey: "listener") as? FakeQuery
        query?.triggerSnapshot([fakeDoc])

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.messages.count, 1)
            XCTAssertEqual(viewModel.messages.first?.text, "Hello world!")
        }
    }
}


//
//class AuthViewModelTests: XCTestCase {
//    var viewModel: TestableAuthViewModel!
//    
//    override func setUp() {
//        super.setUp()
//        viewModel = TestableAuthViewModel()
//    }
//    
//    override func tearDown() {
//        viewModel = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Testable AuthViewModel Subclass
//    
//    class TestableAuthViewModel: AuthViewModel {
//        var mockAuth = MockAuth()
//        var mockFirestore = MockFirestore()
//        
//        override init() {
//            super.init()
//            // Cast our mock to Firestore
//            self.db = unsafeBitCast(mockFirestore, to: Firestore.self)
//        }
//    }
//    
//    // MARK: - Mock Auth
//    
//    class MockAuth {
//        var currentUser: FirebaseAuth.User?
//        var shouldSucceed = true
//        let mockError = NSError(domain: "mock", code: 1, userInfo: nil)
//        
//        func signIn(withEmail email: String, password: String) async throws -> MockAuthDataResult {
//            if shouldSucceed {
//                let user = MockFirebaseUser(uid: "testUID", email: email)
//                currentUser = user
//                return MockAuthDataResult(user: user)
//            } else {
//                throw mockError
//            }
//        }
//        
//        func createUser(withEmail email: String, password: String) async throws -> MockAuthDataResult {
//            if shouldSucceed {
//                let user = MockFirebaseUser(uid: "testUID", email: email)
//                currentUser = user
//                return MockAuthDataResult(user: user)
//            } else {
//                throw mockError
//            }
//        }
//        
//        func signOut() throws {
//            if shouldSucceed {
//                currentUser = nil
//            } else {
//                throw mockError
//            }
//        }
//    }
//    
//    struct MockAuthDataResult {
//        let user: FirebaseAuth.User
//        
//        init(user: FirebaseAuth.User) {
//            self.user = user
//        }
//    }
//    
//    // Mock Firebase User
//    class MockFirebaseUser: FirebaseAuth.User {
//        private let _uid: String
//        private let _email: String?
//        
//        init(uid: String, email: String?) {
//            self._uid = uid
//            self._email = email
//            super.init()
//        }
//        
//        required convenience init?(coder: NSCoder) {
//            let uid = coder.decodeObject(forKey: "uid") as? String ?? ""
//            let email = coder.decodeObject(forKey: "email") as? String
//            self.init(uid: uid, email: email)
//        }
//        
//        override var uid: String {
//            get { return _uid }
//            set { /* Mock doesn't need to support setting */ }
//        }
//        
//        override var email: String? {
//            get { return _email }
//            set { /* Mock doesn't need to support setting */ }
//        }
//        
//        // These overrides are needed to satisfy the FirebaseAuth.User requirements
//        override func encode(with coder: NSCoder) {
//            coder.encode(_uid, forKey: "uid")
//            coder.encode(_email, forKey: "email")
//        }
//    }
//    
//    // MARK: - Mock Firestore
//    
//    class MockFirestore {
//        var mockDocumentData: [String: Any]?
//        var shouldSucceed = true
//        let mockError = NSError(domain: "mock", code: 1, userInfo: nil)
//        
//        func collection(_ collectionPath: String) -> MockCollectionReference {
//            return MockCollectionReference(firestore: self)
//        }
//    }
//    
//    class MockCollectionReference {
//        let firestore: MockFirestore
//        
//        init(firestore: MockFirestore) {
//            self.firestore = firestore
//        }
//        
//        func document(_ documentPath: String) -> MockDocumentReference {
//            return MockDocumentReference(firestore: firestore)
//        }
//    }
//    
//    class MockDocumentReference {
//        let firestore: MockFirestore
//        
//        init(firestore: MockFirestore) {
//            self.firestore = firestore
//        }
//        
//        func getDocument(completion: @escaping (MockDocumentSnapshot?, Error?) -> Void) {
//            if firestore.shouldSucceed {
//                let snapshot = MockDocumentSnapshot(data: firestore.mockDocumentData)
//                completion(snapshot, nil)
//            } else {
//                completion(nil, firestore.mockError)
//            }
//        }
//        
//        func setData(_ documentData: [String: Any], completion: ((Error?) -> Void)? = nil) {
//            if firestore.shouldSucceed {
//                firestore.mockDocumentData = documentData
//                completion?(nil)
//            } else {
//                completion?(firestore.mockError)
//            }
//        }
//        
//        func updateData(_ fields: [String: Any], completion: ((Error?) -> Void)? = nil) {
//            if firestore.shouldSucceed {
//                if var existingData = firestore.mockDocumentData {
//                    for (key, value) in fields {
//                        existingData[key] = value
//                    }
//                    firestore.mockDocumentData = existingData
//                } else {
//                    firestore.mockDocumentData = fields
//                }
//                completion?(nil)
//            } else {
//                completion?(firestore.mockError)
//            }
//        }
//    }
//    
//    struct MockDocumentSnapshot {
//        let dataValue: [String: Any]?
//        
//        init(data: [String: Any]?) {
//            self.dataValue = data
//        }
//        
//        func data() -> [String: Any]? {
//            return dataValue
//        }
//        
//        var exists: Bool {
//            return dataValue != nil
//        }
//    }
//    
//    // MARK: - Login Tests
//    
//    func testLoginSuccess() async {
//        // Setup
//        viewModel.mockAuth.shouldSucceed = true
//        viewModel.mockFirestore.mockDocumentData = [
//            "fullname": "Test User",
//            "email": "test@example.com",
//            "preferences": [],
//            "joinedEvents": [],
//            "hostedEvents": []
//        ]
//        
//        // Execute
//        await viewModel.login(withEmail: "test@example.com", password: "password")
//        
//        // Verify
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertFalse(viewModel.showError)
//        XCTAssertNil(viewModel.error)
//        XCTAssertEqual(viewModel.currentUser?.fullname, "Test User")
//    }
//    
//    func testLoginFailure() async {
//        // Setup
//        viewModel.mockAuth.shouldSucceed = false
//        
//        // Execute
//        await viewModel.login(withEmail: "test@example.com", password: "wrongpassword")
//        
//        // Verify
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertTrue(viewModel.showError)
//        XCTAssertNotNil(viewModel.error)
//    }
//    
//    // MARK: - Register Tests
//    
//    func testRegisterSuccess() async {
//        // Setup
//        viewModel.mockAuth.shouldSucceed = true
//        viewModel.mockFirestore.shouldSucceed = true
//        viewModel.mockFirestore.mockDocumentData = [
//            "fullname": "New User",
//            "email": "new@example.com",
//            "preferences": [],
//            "joinedEvents": [],
//            "hostedEvents": []
//        ]
//        
//        // Execute
//        await viewModel.register(withEmail: "new@example.com", password: "password", fullname: "New User")
//        
//        // Verify
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertFalse(viewModel.showError)
//        XCTAssertNil(viewModel.error)
//        XCTAssertEqual(viewModel.currentUser?.fullname, "New User")
//    }
//    
//    func testRegisterFailure() async {
//        // Setup
//        viewModel.mockAuth.shouldSucceed = false
//        
//        // Execute
//        await viewModel.register(withEmail: "new@example.com", password: "password", fullname: "New User")
//        
//        // Verify
//        XCTAssertFalse(viewModel.isLoading)
//        XCTAssertTrue(viewModel.showError)
//        XCTAssertNotNil(viewModel.error)
//    }
//    
//    // MARK: - Sign Out Tests
//    
//    func testSignOutSuccess() {
//        // Setup
//        viewModel.userSession = MockFirebaseUser(uid: "testUID", email: "test@test.com")
//        viewModel.currentUser = ALP_MAD.User(id: "testUID", fullname: "Test", email: "test@test.com")
//        viewModel.mockAuth.shouldSucceed = true
//        
//        // Execute
//        viewModel.signOut()
//        
//        // Verify
//        XCTAssertNil(viewModel.userSession)
//        XCTAssertNil(viewModel.currentUser)
//        XCTAssertFalse(viewModel.showError)
//    }
//    
//    func testSignOutFailure() {
//        // Setup
//        viewModel.userSession = MockFirebaseUser(uid: "testUID", email: "test@test.com")
//        viewModel.currentUser = ALP_MAD.User(id: "testUID", fullname: "Test", email: "test@test.com")
//        viewModel.mockAuth.shouldSucceed = false
//        
//        // Execute
//        viewModel.signOut()
//        
//        // Verify
//        XCTAssertNotNil(viewModel.userSession)
//        XCTAssertNotNil(viewModel.currentUser)
//        XCTAssertTrue(viewModel.showError)
//        XCTAssertNotNil(viewModel.error)
//    }
//    
//    // MARK: - Fetch User Tests
//    
//    func testFetchUserSuccess() async {
//        // Setup
//        viewModel.mockAuth.currentUser = MockFirebaseUser(uid: "testUID", email: "test@test.com")
//        viewModel.userSession = viewModel.mockAuth.currentUser
//        viewModel.mockFirestore.mockDocumentData = [
//            "fullname": "Fetched User",
//            "email": "fetched@example.com",
//            "preferences": [],
//            "joinedEvents": [],
//            "hostedEvents": []
//        ]
//        
//        // Execute
//        await viewModel.fetchUser()
//        
//        // Verify
//        XCTAssertEqual(viewModel.currentUser?.fullname, "Fetched User")
//        XCTAssertFalse(viewModel.showError)
//    }
//    
//    func testFetchUserNoSession() async {
//        // Setup
//        viewModel.userSession = nil
//        
//        // Execute
//        await viewModel.fetchUser()
//        
//        // Verify
//        XCTAssertNil(viewModel.currentUser)
//        XCTAssertFalse(viewModel.showError)
//    }
//    
//    func testFetchUserFailure() async {
//        // Setup
//        viewModel.mockAuth.currentUser = MockFirebaseUser(uid: "testUID", email: "test@test.com")
//        viewModel.userSession = viewModel.mockAuth.currentUser
//        viewModel.mockFirestore.shouldSucceed = false
//        
//        // Execute
//        await viewModel.fetchUser()
//        
//        // Verify
//        XCTAssertNil(viewModel.currentUser)
//        XCTAssertTrue(viewModel.showError)
//        XCTAssertNotNil(viewModel.error)
//    }
//    
//    // MARK: - Update Profile Tests
//    
//    func testUpdateProfileSuccess() async throws {
//        // Setup
//        viewModel.currentUser = ALP_MAD.User(id: "testUID", fullname: "Old Name", email: "test@test.com")
//        viewModel.mockFirestore.shouldSucceed = true
//        
//        // Execute
//        try await viewModel.updateProfile(fullname: "New Name", image: nil)
//        
//        // Verify
//        XCTAssertEqual(viewModel.currentUser?.fullname, "New Name")
//    }
//    
//    func testUpdateProfileFailure() async {
//        // Setup
//        viewModel.currentUser = ALP_MAD.User(id: "testUID", fullname: "Old Name", email: "test@test.com")
//        viewModel.mockFirestore.shouldSucceed = false
//        
//        // Execute & Verify
//        do {
//            try await viewModel.updateProfile(fullname: "New Name", image: nil)
//            XCTFail("Expected error to be thrown")
//        } catch {
//            XCTAssertNotNil(error)
//        }
//    }
//}
