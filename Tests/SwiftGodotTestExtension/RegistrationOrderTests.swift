//
//  RegistrationOrderTests.swift
//  SwiftGodotTestExtension
//
//  Tests that classes are registered in the correct initialization level order
//

import SwiftGodot

// MARK: - Test classes registered at different initialization levels
// Declaration order is intentionally mixed to test that registration respects initialization levels

/// Class at .scene level (declared first, but depends on CoreLevelClass)
@Godot
class SceneLevelClass: ServersLevelClass {
    override class var classInitializationLevel: ExtensionInitializationLevel { .scene }
}

/// Another class at .scene level
@Godot
class AnotherSceneLevelClass: SceneLevelClass {
}

/// Class at .core level (declared in the middle, but should be registered first)
@Godot
class CoreLevelClass: RefCounted {
    override class var classInitializationLevel: ExtensionInitializationLevel { .core }
}

/// Class at .servers level (depends on CoreLevelClass)
@Godot
class ServersLevelClass: CoreLevelClass {
    override class var classInitializationLevel: ExtensionInitializationLevel { .servers }
}

/// Yet another class at .scene level to test multiple classes at same level
@Godot
class ThirdSceneLevelClass: RefCounted {
}

// MARK: - Tests

@SwiftGodotTestSuite
final class RegistrationOrderTests {
    func testRegisteredClassesExistInClassDB() {
        // Verify that all test classes are actually registered in Godot's ClassDB
        assertTrue(ClassDB.classExists(class: "CoreLevelClass"), "CoreLevelClass should exist in ClassDB")
        assertTrue(ClassDB.classExists(class: "ServersLevelClass"), "ServersLevelClass should exist in ClassDB")
        assertTrue(ClassDB.classExists(class: "SceneLevelClass"), "SceneLevelClass should exist in ClassDB")
        assertTrue(ClassDB.classExists(class: "AnotherSceneLevelClass"), "AnotherSceneLevelClass should exist in ClassDB")
        assertTrue(ClassDB.classExists(class: "ThirdSceneLevelClass"), "ThirdSceneLevelClass should exist in ClassDB")
    }

    func testClassInheritanceIsCorrect() {
        // Verify that the inheritance chain is correct in ClassDB
        assertEqual(ClassDB.getParentClass("CoreLevelClass"), "RefCounted")
        assertEqual(ClassDB.getParentClass("ServersLevelClass"), "CoreLevelClass")
        assertEqual(ClassDB.getParentClass("SceneLevelClass"), "ServersLevelClass")
        assertEqual(ClassDB.getParentClass("AnotherSceneLevelClass"), "SceneLevelClass")
        assertEqual(ClassDB.getParentClass("ThirdSceneLevelClass"), "RefCounted")
    }

    func testInstancesReportCorrectClassName() {
        // Verify that instances report their correct class name via Godot's type system
        let coreInstance = CoreLevelClass()
        assertEqual(coreInstance.getClass(), "CoreLevelClass")

        let serversInstance = ServersLevelClass()
        assertEqual(serversInstance.getClass(), "ServersLevelClass")

        let sceneInstance = SceneLevelClass()
        assertEqual(sceneInstance.getClass(), "SceneLevelClass")

        let anotherSceneInstance = AnotherSceneLevelClass()
        assertEqual(anotherSceneInstance.getClass(), "AnotherSceneLevelClass")

        let thirdSceneInstance = ThirdSceneLevelClass()
        assertEqual(thirdSceneInstance.getClass(), "ThirdSceneLevelClass")
    }

    func testClassesHaveCorrectInitializationLevels() {
        assertEqual(CoreLevelClass.classInitializationLevel, .core)
        assertEqual(ServersLevelClass.classInitializationLevel, .servers)
        assertEqual(SceneLevelClass.classInitializationLevel, .scene)
        assertEqual(AnotherSceneLevelClass.classInitializationLevel, .scene)
        assertEqual(ThirdSceneLevelClass.classInitializationLevel, .scene)
    }
}
