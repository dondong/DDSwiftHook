## Example
```code
class TargetClass {
    func targetFunction() {
        // do something
    }
}

class TargetClassEmpty : TargetClass {  // An empty class for save objc origin function
}
class TargetClassHook : TargetClassEmpty, DDSwiftHookable {
    override func targetFunction() {
        super.targetFunction();  // call origin function
    } 
}

TargetClassHook.enableHook();  // do hook

```
## Author

dondong, the-last-choice@qq.com

## License

DDSwiftHook is available under the MIT license. See the LICENSE file for more info.
