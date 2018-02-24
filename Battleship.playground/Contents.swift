// Battleship: A Game of War & Protocol

/// A simple 2D Position expressed as (x,y) via integers
struct Coordinate {
	/// Horizontal position of coordinate.
	let x:Int
	/// Vertical position of coordinate.
	let y:Int
}

// We need to be able to compare coordinates
// Our struct will get this from the compiler for free in Swift 4.1 or 5????
extension Coordinate: Equatable {
	/// Determines if coordinates are equal.
	static func ==(lhs:Coordinate, rhs:Coordinate) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

// Lets make coordinates print pretty, (x,y), by adopting CustomStringConvertible from the standard library.
// CustomStringConvertible is the protocol used to output a a custom string for any conforming Type.
// This protocol defines "description" as a property that returns a string.
extension Coordinate: CustomStringConvertible {
	var description: String {
		return "(\(x),\(y))"
	}
}

// The direction our ships point at sea.
/// A simple enum indicating directional heading of objects in a 2D grid.
enum Orientation {
	case horizontal, vertical
}

/// A protocol for declaring a type can be displayed on the grid.
protocol GridCoordinateRepresentable {
	/// The grid coordinates the type occupies.
	var coordinates: [Coordinate] { get set }
	
	/// All conforming types should have this initializer.
	init(coordinates: [Coordinate])
}

// With the power of Protocol Oriented Programming, AKA POP, we can add default functionality to any type conforming to the protocol.
// When you do this you can actually define a default function in the protocol extension that any conforming type can use for free.
extension GridCoordinateRepresentable {
	/// All conforming types can use this initializer for free.
	///
	/// - Parameters:
	///   - origin: The starting `Coordinate`
	///   - orientation: The directional `Orientation` of `coordinates`
	///   - length: number of coordinate spaces occupied.
	init (origin: Coordinate, orientation: Orientation, length: Int) {
		self.init(coordinates: [origin])
		switch orientation {
		case .horizontal:
			for x in origin.x + 1...length - 1 + origin.x {
				coordinates.append(Coordinate(x: x, y: origin.y))
			}
		case .vertical:
			for y in origin.y + 1...length - 1 + origin.y {
				coordinates.append(Coordinate(x: origin.x, y: y))
			}
		}
	}
}


// The Battleship!!!!
/// A simple struct to represent ships on the grid.
struct Battleship {
	/// The grid coordinates the ship occupies.
	var coordinates: [Coordinate]
}


// Our Battleship needs to be represented on the grid so we'll conform to GridCoordinateRepresentable.
extension Battleship: GridCoordinateRepresentable {}

// Lets' also make Battleship print a nice list of it's coordinates.
// You don't have to make these structs declare and conform to Protocols in extensions.
// You could just as easily do it in the struct definition, but using extensions helps
// to break your code up into logical chunks and a little easier to manage.
extension Battleship: CustomStringConvertible {
	var description: String {
		var text = "Battleship at Coordinates: "
		for c in coordinates {
			text += c.description + " "
		}
		return text
	}
}

// Let's make something nicer and more flexible than a bool to report torpedo success with.
/// A simple enum for torpedo results.
enum TorpedoResult: CustomStringConvertible {
	case hit, miss // we may want to add a "nearMiss" possibility later
	var description: String {
		switch self {
		case .hit: return "😡 You sunk my battleship!"
		case .miss: return "😎 Not even close Mister!"
		}
	}
}

// Now we'll create a protocol called HitDetectable.
/// This protocol requires conforming Types to have an array property `coordinates` and a function called testForHitAt(coordinate).
protocol HitDetectable {
	/// The coordinate spaces your type occupies.
	var coordinates: [Coordinate] { get set }
	/// Checks if incoming torpedos hit any of your coordinates.
	/// - parameter at: The `Coordinate` to check for hit.
	func testForHit(at coordinate: Coordinate) -> TorpedoResult
}

// Instead of placing the required testForHitAt() method in an extension to Battleship,
// we'll once again put it into an extension of the protocol itself.
extension HitDetectable {
	func testForHit(at coordinate: Coordinate) -> TorpedoResult {
		// This works because the compiler knows that any type conforming
		// to the protocol has a variable called "coordinates" that holds
		// Coordinate type items that conform to Equatable
		if self.coordinates.contains(coordinate) {
			return .hit
		}
		return .miss
	}
}

// Now let's get all crazy and also make Torpedo launching into a reusable Protocol as well
/// This protocol declares that a conforming type can shoot torpedos at any typr that is `HitDetectable`.
protocol TorpedoLaunchable {
	// Note we are launching torpedos at HitDetecable types, not Battleships.
	// This makes this protocol extremely flexible for reuse as well.
	func launchTorpedo(at target: HitDetectable, with coordinate: Coordinate) -> TorpedoResult
}

// Again we'll take advantage of POP and extend the protocol with a default shootTorpedoAt(_,_) implementation.
extension TorpedoLaunchable {
	func launchTorpedo(at target: HitDetectable, with coordinate: Coordinate) -> TorpedoResult {
		return target.testForHit(at: coordinate)
	}
}

// Now we'll add these new protocols to Battleship
extension Battleship: HitDetectable, TorpedoLaunchable {}

// And Finally We'll make our ships and go to war!!!!
let ship1 = Battleship(origin: Coordinate(x: 2, y: 1), orientation: .vertical, length: 3)
let ship2 = Battleship(origin: Coordinate(x: 6, y: 4), orientation: .horizontal, length: 5)
let torpedoResults = ship1.launchTorpedo(at: ship2, with: Coordinate(x: 0, y: 2))
let secondTorpedoResult = ship2.launchTorpedo(at: ship1, with: Coordinate(x: 2, y: 2))

// Just before ship1 went down they were able to radio back to base.
// It's a funny thing, war. Ships aren't the only things to go to war.
// Basically anything that occupies grid coordinates and can use torpedoes can go to war.
// So any types conforming to the required protocols can go to war with each other.
// The homebase of ship1 has assembled an army and predictably
// Armies can also occupy spots on the grid, well on the sea shore anyway.
struct Army {
	/// The grid coordinates the ship occupies.
	var coordinates: [Coordinate]
}

// We need the army to have the same capabilities of our battleships even though they are a different type.
// Instead of conforming to each individual protocol, we'll use the power of protocol composition
// to make a super-protocol called GridCoordinateCombatant.
typealias GridCoordinateCombatant = GridCoordinateRepresentable & TorpedoLaunchable & HitDetectable

// Our Army conforms to the new super protocol.
// Now despite being an entirely different type from Battleship,
// It can share all the default implementations from all the protocol extensions.
extension Army: GridCoordinateCombatant {}

// The Army is being assembled on the shore now to line the whole coast.
let armyOfVengance = Army(origin:  Coordinate(x: 2, y: 6) , orientation: .vertical, length: 20)

// And they promptly get ship2 in their sights and fire a torpedo.
armyOfVengance.launchTorpedo(at: ship2, with:  Coordinate(x: 7, y: 4))

