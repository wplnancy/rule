// 测试代码审查工具
var oldVar = "应该使用 let 或 const"
console.log("这里有 console.log")

function longFunction() {
    var anotherVar = "这是一个非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常长的字符串，应该被检测出来"
    // TODO: 这里需要优化
    return oldVar + anotherVar
}