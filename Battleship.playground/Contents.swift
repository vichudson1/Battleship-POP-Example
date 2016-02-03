// Battleship: A Game of War & Protocol

// A simple 2D Position
struct Coordinate {
	var x:Int
	var y:Int
}

// The Extension is empty because the Equatable Protocol doesn't define any methods or variables except for the func ==(_,_) which is an operator overloader which must go in the global scope.
extension Coordinate: Equatable {}
func ==(lhs:Coordinate, rhs:Coordinate) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

// Lets make Coordinates Print Pretty - (x,y). CustomStringConvertible is the protocol used to output a a custom string for any conforming Type. This protocol only defines "description" as a computed property that returns a string.
extension Coordinate: CustomStringConvertible {
	var description: String {
		return "(\(x),\(y))"
	}
}

// The direction our ships point at sea.
enum Orientation {
	case horizontal, vertical
}

// The Battleship!!!!
struct Battleship {
	var coordinates: [Coordinate]
	var orientation: Orientation
	var length: Int
	init (origin: Coordinate, orientation: Orientation, length: Int) {
		self.orientation = orientation
		self.length = length
		
		self.coordinates = [origin]
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

// Lets make Battleship Print A nice list of it's coordinates. You don't have to make these structs declare and conform to Protocols in extensions. You could just as easily do it in the struct definition, but using extensions helps to break your code up into logical chunks and a little easier to manage.
extension Battleship: CustomStringConvertible {
	var description: String {
		var text = "Battleship at Coordinates: "
		for c in coordinates {
			text += c.description + " "
		}
		return text
	}
}

// Let's make something nicer and more flexible than a bool to report torpedo success with
enum TorpedoResult: CustomStringConvertible {
	case hit, miss // we may want to add a "nearMiss" possibility later
	var description: String {
		switch self {
		case .hit: return "You sunk my battleship! 😡"
		case .miss: return "Not even close Mister! 😎"
		}
	}
}

// Now just for the fun of it, we'll create a protocol called HitDetectable so you'll have an example of that as well. This protocol requires conforming Types to have an array variable of Coordinates and a function called testForHitAt(coordinate). You could then use this protocol on lots of different Types.
protocol HitDetectable {
	var coordinates: [Coordinate] { get set }
	func testForHitAt(coordinate: Coordinate) -> TorpedoResult
}

// We'll also demonstrate the joy of POP. Instead of placing the required testForHitAt() method in an extension to Battleship, we'll put it into an extension of the protocol itself.When you do this you can actually define a default function in the protocol extension that any conforming Type can use for free.
extension HitDetectable {
	func testForHitAt(coordinate: Coordinate) -> TorpedoResult {
		// This works because the compiler knows that any type conforming
		// to the protocol has a variable called "coordinates" that holds
		// Coordinate type items that conform to Equatable
		if self.coordinates.contains(coordinate) {
			return .hit
		}
		return .miss
	}
}

// Let's get all crazy and also make Torpedo launching into a reusable Protocol as well
protocol TorpedoLaunchable {
	// Note we are launching torpedos at HitDetecable Types, not Battleships.
	// This makes this protocol extremely flexible for reuse as well.
	func shootTorpedoAt(target: HitDetectable, hopefullyAtCoordinate coordinate: Coordinate) -> TorpedoResult
}

// Again we'll take advantage of POP and extend the protocol with a default shootTorpedoAt(_,_) implementation.
extension TorpedoLaunchable {
	func shootTorpedoAt(target: HitDetectable, hopefullyAtCoordinate coordinate: Coordinate) -> TorpedoResult {
		return target.testForHitAt(coordinate)
	}
}

// Now we'll add these new protocols to Battleship
extension Battleship: HitDetectable, TorpedoLaunchable {}

// And Finally We'll make our ships and go to war!!!!
let ship1 = Battleship(origin: Coordinate(x: 2, y: 1), orientation: .vertical, length: 3)
let ship2 = Battleship(origin: Coordinate(x: 6, y: 4), orientation: .horizontal, length: 5)

let torpedoResults = ship1.shootTorpedoAt(ship2, hopefullyAtCoordinate: Coordinate(x: 0, y: 2))
let secondTorpedoResult = ship2.shootTorpedoAt(ship1, hopefullyAtCoordinate: Coordinate(x: 2, y: 2))
