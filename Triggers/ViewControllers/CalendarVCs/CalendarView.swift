//
//  CalendarView.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/1/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//


import UIKit

struct Colors {
    static var darkGray = MyColor.softGreen.value
    static var darkRed = UIColor.red
}

struct Style {
    static var bgColor = UIColor.white
    static var monthViewLblColor = UIColor.white
    static var monthViewBtnRightColor = UIColor.white
    static var monthViewBtnLeftColor = UIColor.red
    static var activeCellLblColor = UIColor.white
    static var activeCellLblColorHighlighted = UIColor.black
    static var weekdaysLblColor = UIColor.red
    
    static func themeDark(){
        bgColor = Colors.darkGray
        monthViewLblColor = UIColor.purple
        monthViewBtnRightColor = UIColor.blue
        monthViewBtnLeftColor = UIColor.red
        activeCellLblColor = UIColor.white
        activeCellLblColorHighlighted = UIColor.yellow
        weekdaysLblColor = UIColor.brown
    }
    
    static func themeLight(){
        bgColor = UIColor.white
        monthViewLblColor = UIColor.black
        monthViewBtnRightColor = UIColor.black
        monthViewBtnLeftColor = UIColor.black
        activeCellLblColor = UIColor.black
        activeCellLblColorHighlighted = UIColor.red
        weekdaysLblColor = UIColor.black
    }
}

class CalenderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    convenience init(theme: MyTheme) {
        self.init()
        
        if theme == .dark {
            Style.themeDark()
        } else {
            Style.themeLight()
        }
        
        initializeView()
    }
    
    func changeTheme() {
        myCollectionView.reloadData()
        
        monthView.nameLabel.textColor = Style.monthViewLblColor
        monthView.rightButton.setTitleColor(Style.monthViewBtnRightColor, for: .normal)
        monthView.leftButon.setTitleColor(Style.monthViewBtnLeftColor, for: .normal)
        
        for i in 0..<7 {
            (weekdaysView.myStackView.subviews[i] as! UILabel).textColor = Style.weekdaysLblColor
        }
    }
    
    func initializeView() {
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
        
        //for leap years, make february month reflect 29 days
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        
        presentMonthIndex = currentMonthIndex
        presentYear = currentYear
        
        setupViews()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.backgroundColor = UIColor.clear
        
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden = true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth + 2
            cell.isHidden = false
            cell.dayNumericValue.text="\(calcDate)"
            
            if calcDate < todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex {
                cell.isUserInteractionEnabled = false
                cell.dayNumericValue.textColor = UIColor.green
            } else {
                cell.isUserInteractionEnabled = true
                cell.dayNumericValue.textColor = Style.activeCellLblColor
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        print("\n\nDate Selected:\(String(describing: cell?.description))\n\n")
        
        cell?.backgroundColor = MyColor.hardBlue.value
        
        let cellLabel = cell?.subviews[1] as! UILabel
        
        print("\n\nDate Selected: \(String(describing: cellLabel.text))\n\n")
        cellLabel.textColor = UIColor.white
    }
    
    //User selected a cell the label will turn the set color once it is unselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor = UIColor.clear
        
        let cellLabel = cell?.subviews[1] as! UILabel
        cellLabel.textColor = MyColor.offWhite.value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7 - 8
        let height: CGFloat = 40
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        //Return day == 7 ? 1 : day
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        currentMonthIndex = monthIndex + 1
        currentYear = year
        
        //For leap year, make february month reflect 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        //end
        firstWeekDayOfMonth = getFirstWeekDay()
        
        myCollectionView.reloadData()
        
        monthView.leftButon.isEnabled = !(currentMonthIndex == presentMonthIndex && currentYear == presentYear)
    }
    
    func setupViews() {
        addSubview(monthView)
        monthView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        monthView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        monthView.delegate = self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor).isActive = true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        weekdaysView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive = true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    let monthView: MonthView = {
        let monthView = MonthView()
        monthView.translatesAutoresizingMaskIntoConstraints = false
        
        return monthView
    }()
    
    let weekdaysView: WeekdaysView = {
        let weekDayView = WeekdaysView()
        weekDayView.translatesAutoresizingMaskIntoConstraints = false
        
        return weekDayView
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints = false
        myCollectionView.backgroundColor = UIColor.clear
        myCollectionView.allowsMultipleSelection = false
        
        return myCollectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class dateCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(dayNumericValue)
        dayNumericValue.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dayNumericValue.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dayNumericValue.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dayNumericValue.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    let dayNumericValue: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = MyColor.softGreen.value
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//Get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//Get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}














