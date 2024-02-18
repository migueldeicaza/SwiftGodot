// Based on godot/tests/core/math/test_astar.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
private final class ABCX: AStar3D {
    
    static let A: Int = 0
    static let B: Int = 1
    static let C: Int = 2
    static let X: Int = 3
    
    required init () {
        super.init ()
        
        addPoint (id: Self.A, position: Vector3 (x: 0, y: 0, z: 0))
        addPoint (id: Self.B, position: Vector3 (x: 1, y: 0, z: 0))
        addPoint (id: Self.C, position: Vector3 (x: 0, y: 1, z: 0))
        addPoint (id: Self.X, position: Vector3 (x: 0, y: 0, z: 1))
        connectPoints (id: Self.A, toId: Self.B)
        connectPoints (id: Self.A, toId: Self.C)
        connectPoints (id: Self.B, toId: Self.C)
        connectPoints (id: Self.X, toId: Self.A)
    }
    
    required init (nativeHandle: UnsafeRawPointer) {
        super.init (nativeHandle: nativeHandle)
    }
    
    // Disable heuristic completely.
    override func _computeCost (fromId: Int, toId: Int) -> Double {
        if fromId == Self.A && toId == Self.C {
            return 1000
        }
        return 100
    }
    
}

final class AStarTests: GodotTestCase {
    
    override class var godotSubclasses: [Wrapped.Type] {
        return [ABCX.self]
    }
    
    func testAbcPath () {
        let abcx = ABCX ()
        let path = abcx.getIdPath (fromId: ABCX.A, toId: ABCX.C)
        XCTAssertEqual (path.size (), 3)
        XCTAssertEqual (path [safe: 0], Int64 (ABCX.A))
        XCTAssertEqual (path [safe: 1], Int64 (ABCX.B))
        XCTAssertEqual (path [safe: 2], Int64 (ABCX.C))
    }

    func testAbcxPath () {
        let abcx = ABCX ()
        let path = abcx.getIdPath (fromId: ABCX.X, toId: ABCX.C)
        XCTAssertEqual (path.size (), 4)
        XCTAssertEqual (path [safe: 0], Int64 (ABCX.X))
        XCTAssertEqual (path [safe: 1], Int64 (ABCX.A))
        XCTAssertEqual (path [safe: 2], Int64 (ABCX.B))
        XCTAssertEqual (path [safe: 3], Int64 (ABCX.C))
    }
    
    func testAddRemove () {
        let a = AStar3D ()
        
        // Manual tests.
        a.addPoint (id: 1, position: Vector3 (x: 0, y: 0, z: 0))
        a.addPoint (id: 2, position: Vector3 (x: 0, y: 1, z: 0))
        a.addPoint (id: 3, position: Vector3 (x: 1, y: 1, z: 0))
        a.addPoint (id: 4, position: Vector3 (x: 2, y: 0, z: 0))
        a.connectPoints (id: 1, toId: 2, bidirectional: true)
        a.connectPoints (id: 1, toId: 3, bidirectional: true)
        a.connectPoints (id: 1, toId: 4, bidirectional: false)
        
        XCTAssertTrue (a.arePointsConnected (id: 2, toId: 1))
        XCTAssertTrue (a.arePointsConnected (id: 4, toId: 1))
        XCTAssertTrue (a.arePointsConnected (id: 2, toId: 1, bidirectional: false))
        XCTAssertFalse (a.arePointsConnected (id: 4, toId: 1, bidirectional: false))
        
        a.disconnectPoints (id: 1, toId: 2, bidirectional: true)
        XCTAssertEqual (a.getPointConnections (id: 1).size (), 2) // 3, 4
        XCTAssertEqual (a.getPointConnections (id: 2).size (), 0)
        
        a.disconnectPoints (id: 4, toId: 1, bidirectional: false)
        XCTAssertEqual (a.getPointConnections (id: 1).size (), 2) // 3, 4
        XCTAssertEqual (a.getPointConnections (id: 4).size (), 0)
        
        a.disconnectPoints (id: 4, toId: 1, bidirectional: true)
        XCTAssertEqual (a.getPointConnections (id: 1).size (), 1) // 3
        XCTAssertEqual (a.getPointConnections (id: 4).size (), 0)
        
        a.connectPoints (id: 2, toId: 3, bidirectional: false)
        XCTAssertEqual (a.getPointConnections (id: 2).size (), 1) // 3
        XCTAssertEqual (a.getPointConnections (id: 3).size (), 1) // 1
        
        a.connectPoints (id: 2, toId: 3, bidirectional: true)
        XCTAssertEqual (a.getPointConnections (id: 2).size (), 1) // 3
        XCTAssertEqual (a.getPointConnections (id: 3).size (), 2) // 1, 2
        
        a.disconnectPoints (id: 2, toId: 3, bidirectional: false)
        XCTAssertEqual (a.getPointConnections (id: 2).size (), 0)
        XCTAssertEqual (a.getPointConnections (id: 3).size (), 2) // 1, 2
        
        a.connectPoints (id: 4, toId: 3, bidirectional: true)
        XCTAssertEqual (a.getPointConnections (id: 3).size (), 3) // 1, 2, 4
        XCTAssertEqual (a.getPointConnections (id: 4).size (), 1) // 3
        
        a.disconnectPoints (id: 3, toId: 4, bidirectional: false)
        XCTAssertEqual (a.getPointConnections (id: 3).size (), 2) // 1, 2
        XCTAssertEqual (a.getPointConnections (id: 4).size (), 1) // 3
        
        a.removePoint (id: 3)
        XCTAssertEqual (a.getPointConnections (id: 1).size (), 0)
        XCTAssertEqual (a.getPointConnections (id: 2).size (), 0)
        XCTAssertEqual (a.getPointConnections (id: 4).size (), 0)
        
        a.addPoint (id: 0, position: Vector3 (x: 0, y: -1, z: 0))
        a.addPoint (id: 3, position: Vector3 (x: 2, y: 1, z: 0))
        // 0: (0, -1)
        // 1: (0, 0)
        // 2: (0, 1)
        // 3: (2, 1)
        // 4: (2, 0)
        
        // Tests for getClosestPositionInSegment.
        a.connectPoints (id: 2, toId: 3)
        XCTAssertEqual (a.getClosestPositionInSegment (toPosition: Vector3 (x: 0.5, y: 0.5, z: 0)), Vector3 (x: 0.5, y: 1, z: 0))
        
        a.connectPoints (id: 3, toId: 4)
        a.connectPoints (id: 0, toId: 3)
        a.connectPoints (id: 1, toId: 4)
        a.disconnectPoints (id: 1, toId: 4, bidirectional: false)
        a.disconnectPoints (id: 4, toId: 3, bidirectional: false)
        a.disconnectPoints (id: 3, toId: 4, bidirectional: false)
        // Remaining edges: <2, 3>, <0, 3>, <1, 4> (directed).
        XCTAssertEqual (a.getClosestPositionInSegment (toPosition: Vector3 (x: 2, y: 0.5, z: 0)), Vector3 (x: 1.75, y: 0.75, z: 0))
        XCTAssertEqual (a.getClosestPositionInSegment (toPosition: Vector3 (x: -1, y: 0.2, z: 0)), Vector3 (x: 0, y: 0, z: 0))
        XCTAssertEqual (a.getClosestPositionInSegment (toPosition: Vector3 (x: 3, y: 2, z: 0)), Vector3 (x: 2, y: 1, z: 0))
        
        // Random tests for connectivity checks
        for i in 0..<2000 {
            let u: Int = Int.random (in: 0..<5)
            var v: Int = Int.random (in: 0..<4)
            if u == v {
                v = 4
            }
            if Bool.random () {
                // Add a (possibly existing) directed edge and confirm connectivity.
                a.connectPoints (id: u, toId: v, bidirectional: false)
                XCTAssertTrue (a.arePointsConnected (id: u, toId: v, bidirectional: false))
            } else {
                // Remove a (possibly nonexistent) directed edge and confirm disconnectivity.
                a.disconnectPoints (id: u, toId: v, bidirectional: false)
                XCTAssertFalse (a.arePointsConnected (id: u, toId: v, bidirectional: false))
            }
        }
        
        // Random tests for point removal.
        for i in 0..<2000 {
            a.clear ()
            for j in 0..<5 {
                a.addPoint (id: j, position: Vector3 (x: 0, y: 0, z: 0))
            }
            // Add or remove random edges.
            for j in 0..<10 {
                let u: Int = Int.random (in: 0..<5)
                var v: Int = Int.random (in: 0..<4)
                if u == v {
                    v = 4
                }
                if Bool.random () {
                    a.connectPoints (id: u, toId: v, bidirectional: false)
                } else {
                    a.disconnectPoints (id: u, toId: v, bidirectional: false)
                }
            }
        
            // Remove point 0.
            a.removePoint (id: 0)
            // White box: this will check all edges remaining in the segments set.
            for j in 0..<5 {
                XCTAssertFalse (a.arePointsConnected (id: 0, toId: j, bidirectional: true))
            }
        }
        // It's been great work, cheers. \(^ ^)/
    }
    
    func testFindPaths () {
        // Random stress tests with Floyd-Warshall.
        let N: Int = 30
        
        for _ in 0..<100 {
            let a = AStar3D ()
            var p: [Vector3] = [Vector3].init (repeating: Vector3.zero, count: N)
            var adj: [[Bool]] = [[Bool]].init (repeating: [Bool].init (repeating: false, count: N), count: N)
            
            // Assign initial coordinates.
            for u in 0..<N {
                p [u].x = .random (in: 0..<100)
                p [u].y = .random (in: 0..<100)
                p [u].z = .random (in: 0..<100)
                a.addPoint (id: u, position: p [u])
            }
            // Generate a random sequence of operations.
            for _ in 0..<100 {
                // Pick two different vertices.
                let u: Int = Int.random (in: 0..<N)
                var v: Int = Int.random (in: 0..<N-1)
                if u == v {
                    v = N - 1
                }
                // Pick a random operation.
                let op: Int = Int.random (in: 0..<Int.max)
                switch op % 9 {
                // Add edge (u, v); possibly bidirectional.
                case 0, 1, 2, 3, 4, 5:
                    a.connectPoints (id: u, toId: v, bidirectional: op % 2 == 1)
                    adj [u][v] = true
                    if op % 2 == 1 {
                        adj [v][u] = true
                    }
                // Remove edge (u, v); possibly bidirectional.
                case 6, 7:
                    a.disconnectPoints (id: u, toId: v, bidirectional: op % 2 == 1)
                    adj [u][v] = false
                    if op % 2 == 1 {
                        adj [v][u] = false
                    }
                // Remove point u and add it back; clears adjacent edges and changes coordinates.
                case 8: 
                    a.removePoint (id: u)
                    p [u].x = .random (in: 0..<100)
                    p [u].y = .random (in: 0..<100)
                    p [u].z = .random (in: 0..<100)
                    a.addPoint (id: u, position: p [u])
                    for v in 0..<N {
                        adj [u][v] = false
                        adj [v][u] = false
                    }
                default:
                    break
                }
            }
            // Floyd-Warshall.
            var d: [[Double]] = [[Double]].init (repeating: [Double].init (repeating: 0, count: N), count: N)
            for u in 0..<N {
                for v in 0..<N {
                    d [u][v] = (u == v || adj [u][v]) ? p [u].distanceTo (p [v]) : .infinity
                }
            }
            for w in 0..<N {
                for u in 0..<N {
                    for v in 0..<N {
                        if (d [u][v] > d [u][w] + d [w][v]) {
                            d [u][v] = d [u][w] + d [w][v]
                        }
                    }
                }
            }
            // Display statistics.
            var count: Int = 0
            for u in 0..<N {
                for v in 0..<N {
                    if (adj [u][v]) {
                        count += 1
                    }
                }
            }
            //printVerbose (vformat ("Test #%4d: %3d edges, ", test + 1, count))
            count = 0
            for u in 0..<N {
                for v in 0..<N {
                    if d [u][v].isFinite {
                        count += 1
                    }
                }
            }
            //printVerbose (vformat ("%3d/%d pairs of reachable points\n", count - N, N * (N - 1)))
        
            // Check A*'s output.
            func checkMatches () -> Bool {
                for u in 0..<N {
                    for v in 0..<N {
                        if u != v {
                            let route = a.getIdPath (fromId: u, toId: v)
                            if d [u][v].isFinite {
                                // Reachable.
                                if route.size () == 0 {
                                    //printVerbose (vformat ("From %d to %d: A* did not find a path\n", u, v))
                                    return false
                                }
                                var astarDist: Double = 0
                                for i: Int in 1..<Int (route.size ()) {
                                    if !adj [Int (route [i - 1])][Int (route [i])] {
                                        //printVerbose (vformat ("From %d to %d: edge (%d, %d) does not exist\n", u, v, route [i - 1], route [i]))
                                        return false
                                    }
                                    astarDist += p [Int (route [i - 1])].distanceTo (p [Int (route [i])])
                                }
                                if !astarDist.isEqualApprox (d [u][v]) {
                                    //printVerbose (vformat ("From %d to %d: Floyd-Warshall gives %.6f, A* gives %.6f\n", u, v, d [u][v], astarDist))
                                    return false
                                }
                            } else {
                                // Unreachable.
                                if route.size () > 0 {
                                    //printVerbose (vformat ("From %d to %d: A* somehow found a nonexistent path\n", u, v))
                                    return false
                                }
                            }
                        }
                    }
                }
                return true
            }
            XCTAssertTrue (checkMatches (), "Found all paths.")
        }
    }
    
}
