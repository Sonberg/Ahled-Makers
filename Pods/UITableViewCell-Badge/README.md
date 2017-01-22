# UITableViewCell-Badge
This is a category to add badge to your UITableViewCell easily.

![](https://raw.githubusercontent.com/xn1108100154/UITableViewCell-Badge/master/demo.gif)

## Why?

[TDBadgedCell](https://github.com/tmdvs/TDBadgedCell) is a nice UITableViewCell subclass that adds badges. But sometimes in your project, you don't want your BaseTableViewCell to be a subclass of any cells. Or your BaseTableViewCell is already a subclass of other cell, such as [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell). Now it is when you need `UITableViewCell-Badge`!

## Example Usage

	cell.badgeString = @"8721";
    cell.badgeCornerRadius = @5;
    cell.badgeColor = [UIColor blueColor];
    cell.badgeFont = [UIFont fontWithName:@"Georgia" size:12];

or

	cell.badgeView.text = @"8721";
	
Please see more usage in demo.

## Requirements

* ARC
* iOS 7.0 and above

## Installation

* From [CocoaPods](https://cocoapods.org/): 

```ruby
pod 'UITableViewCell-Badge'
```

* Without CocoaPods: 
Drag the `UITableViewCell-Badge` folder to your project.

## License

UITableViewCell-Badge is available under the MIT license. See the LICENSE file for more info.