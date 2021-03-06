//
//  HistoryTableViewCell.swift
//  
//
//  Created by Nicholas Kaimakis on 10/22/17.
//

import UIKit
import Charts

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setup(period:String, spent:Double, remaining:Double){
        periodLabel.text = period
        let spentEntry = PieChartDataEntry(value: Double(spent), label: "Spent")
        let remainingEntry = PieChartDataEntry(value: Double(remaining), label: "Remaining")
        let dataSet = PieChartDataSet(values: [spentEntry, remainingEntry], label: "")
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueColors = [UIColor.black]
        dataSet.entryLabelFont = UIFont(name: "DidactGothic-Regular", size: 10)!
        dataSet.valueFont = UIFont(name: "DidactGothic-Regular", size: 10)!
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.chartDescription?.text = "" //period
        //pieChart.chartDescription?.font = UIFont(name: "DidactGothic-Regular", size: 10)!
        pieChart.entryLabelFont = UIFont(name: "DidactGothic-Regular", size: 10)!
        
        //This must stay at end
        pieChart.notifyDataSetChanged()
        setFonts()
    }
    func setFonts(){
        periodLabel.font = UIFont(name: "DidactGothic-Regular", size: 15)
    }

}
