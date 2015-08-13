import Foundation

// MARK: - 挑战#1

func mySwap<T>(inout a: T, inout b:T) {
    (a, b) = (b, a)
}

var a = "123", b = "321"

mySwap(&a, &b)

[a, b]

// MARK: - 挑战#2

func flexStrings(s1: String = "", s2: String = "") -> String {
    return s1 + s2 == "" ? "none" : s1 + s2
}

flexStrings()
flexStrings(s1: "One")
flexStrings(s1: "One", s2: "Two")
flexStrings(s1: "", s2: "")

// MARK: - 挑战#3

// Any 表示任意类型,而...则表示参数个数任意,即接收任意数量的任意类型的参数.
// 所有参数会作为一个数组传入,像下面这样,该字符串将表示传入参数的个数.
func sumAny(anys: Any...) -> String {

    return String(
        // 使用 map 函数来遍历数组.每次遍历的返回值最终组成一个新数组返回.
        [Any]().map { item -> Int in

            switch item {

            // 匹配空字符串或者Int类型的0.
            case "" as String, 0 as Int:
                return -10

            // 字符串能转为Int且大于0,返回转换后的值.
            case let s as String where s.toInt() > 0:
                return s.toInt()!

            // 匹配到Int,直接返回.
            case is Int:
                return item as! Int

            // 其他情况返回0,等于没累加.
            default:
                return 0
            }
        }
        // 遍历数组,将每次的返回值累加到函数第一个参数上,这里就是这个0.最后将该参数的作为函数返回值.
        // $0 表示闭包第1个参数, $1 表示闭包第2个参数,以此类推.
        .reduce(0) { $0 + $1 })
}

// MARK: - 挑战#4

func countFrom(from: Int, #to: Int) {
    print(from)
    if from < to {
        countFrom(from + 1, to: to)
    }
}

countFrom(1, to: 5)

// MARK: - 挑战#5

func reverseString(input: String, output: String = "") -> String {
    if input.isEmpty {
        return output
    } else {
        return reverseString(input.substringToIndex(input.endIndex.predecessor()),
            output: output + input.substringFromIndex(input.endIndex.predecessor()))
    }
}

println(reverseString("0123456789"))

// MARK: - 挑战#6

func charMult(#char: Character, var #result: String, #length: Int) -> String {
    if count(result) < length {
        result.append(char)
        return charMult(char: char, result: result, length: length)
    } else {
        return result
    }
}

func * (left: Character, right: Int) -> String {
    return charMult(char: left, result: "", length: right)
}

"-" * 10 + ">" // ---------->
"%" + "~" * 6  // %~~~~~~
"Z" * 20       // ZZZZZZZZZZZZZZZZZZ

// MARK: - 挑战#7

func doWork() -> Bool {
    return arc4random() % 10 < 5
}

func reportTrue() -> Bool {
    println("真")
    return true
}

func reportFalse() -> Bool {
    println("假")
    return true
}

doWork() && reportTrue() || reportFalse()

// MARK: - 挑战#8

extension Array {

    var arrayWithElementAtIndexToFront: Int -> Array {
        return swapElementAtIndex(0)
    }

    var arrayWithElementAtIndexToBack: Int -> Array {
        return swapElementAtIndex(count - 1)
    }

    func swapElementAtIndex(index: Int) -> (withIndex: Int) -> Array {
        return { withIndex in
            var result = self // 一份可变拷贝.
            if index < self.count && withIndex < self.count {
                (result[index], result[withIndex]) = (result[withIndex], result[index])
            }
            return result
        }
    }
}

let list = [1, 2, 3]
list.swapElementAtIndex(1)(withIndex: 2)
list.arrayWithElementAtIndexToFront(1)
list.arrayWithElementAtIndexToBack(1)