//
//  StepsView.swift
//  AspenDental
//
//  Created by Dusan Juranovic on 23.7.21..
//

import UIKit

public class StepView: UIView {
	private var checkCircle = UIImageView()
	private var stepLabel = UILabel()
	private var nextStepPath = UIView()
	private var mainStack = UIStackView()
	private var innerStack = UIStackView()
	
	private var mainStackAxis: NSLayoutConstraint.Axis = .horizontal
	private var subStackAxis: NSLayoutConstraint.Axis = .vertical
	var axis: NSLayoutConstraint.Axis = .vertical {
		didSet {
			switch axis {
				case .vertical:
					mainStackAxis = .horizontal
					subStackAxis = .vertical
				case .horizontal:
					mainStackAxis = .vertical
					subStackAxis = .horizontal
				@unknown default:
					fatalError("Only vertical and horizontal orientations are supported")
			}
			setupViewDisplay()
		}
	}
	var isFinalElement: Bool = false
	var stepTitle: String = ""
	var stepActiveColor: UIColor!
	var stepInactiveColor: UIColor!
	var stepShape: StepShape!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	init(title: String, tag: Int, activeColor: UIColor = .blue, inactiveColor: UIColor = .lightGray, shape: StepShape = .circular) {
		super.init(frame: .zero)
		self.stepTitle = title
		self.tag = tag
		self.stepActiveColor = activeColor
		self.stepInactiveColor = inactiveColor
		self.stepShape = shape
		commonInit()
	}
	
	private func commonInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.checkCircle.image = stepShape == .circular ? UIImage(systemName: "\(tag).circle.fill") : UIImage(systemName: "\(tag).square.fill")
		self.checkCircle.tintColor = self.stepInactiveColor
		self.stepLabel.textColor = .darkGray
		self.stepLabel.font = UIFont(name: "MessinaSans-Book", size: 14)
		self.stepLabel.numberOfLines = 0
		self.stepLabel.text = stepTitle
		self.stepLabel.lineBreakMode = .byWordWrapping
		commonSetupForAxis()
		setupViewDisplay()
	}
	
	private func setupViewDisplay() {
		switch axis {
			case .vertical:
				self.setupForVertical()
			case .horizontal:
				self.cleanupConstraints()
				self.setupForHorizontal()
			default: break
		}
	}
	
	private func cleanupConstraints() {
		self.mainStack.constraints.forEach {$0.isActive = false}
		self.innerStack.constraints.forEach {$0.isActive = false}
		self.checkCircle.constraints.forEach {$0.isActive = false}
		self.stepLabel.constraints.forEach {$0.isActive = false}
		self.nextStepPath.constraints.forEach {$0.isActive = false}
		self.commonSetupForAxis()
	}
	
	private func commonSetupForAxis() {
		self.innerStack.translatesAutoresizingMaskIntoConstraints = false
		self.mainStack.translatesAutoresizingMaskIntoConstraints = false
		
		self.mainStack.addArrangedSubview(innerStack)
		self.mainStack.addArrangedSubview(stepLabel)
		self.addSubview(self.mainStack)
		
		NSLayoutConstraint.activate([
			self.mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.mainStack.topAnchor.constraint(equalTo: self.topAnchor),
			self.mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			
			self.checkCircle.widthAnchor.constraint(equalToConstant: 28),
			self.checkCircle.heightAnchor.constraint(equalToConstant: 28)
		])
	}
	
	private func setupForVertical() {
		self.innerStack.axis = subStackAxis
		self.innerStack.alignment = .center
		self.innerStack.distribution = .fill
		self.innerStack.spacing = 9
		self.innerStack.addArrangedSubview(self.checkCircle)
		self.innerStack.addArrangedSubview(self.nextStepPath)
		
		self.mainStack.distribution = .fill
		self.mainStack.alignment = .top
		self.mainStack.spacing = 13
		self.mainStack.axis = mainStackAxis
		
		NSLayoutConstraint.activate([
			self.innerStack.widthAnchor.constraint(equalToConstant: 28),
			self.innerStack.topAnchor.constraint(equalTo: self.mainStack.topAnchor),
			self.innerStack.bottomAnchor.constraint(equalTo: self.mainStack.bottomAnchor),
			
			self.nextStepPath.widthAnchor.constraint(equalToConstant: 1),
			
			
		])
		self.layoutIfNeeded()
	}
	
	private func setupForHorizontal() {
		self.innerStack.axis = subStackAxis
		self.innerStack.distribution = .fill
		self.innerStack.alignment = .center
		self.innerStack.spacing = 9
		self.innerStack.addArrangedSubview(self.checkCircle)
		self.innerStack.addArrangedSubview(self.nextStepPath)
		
		self.mainStack.distribution = .fill
		self.mainStack.alignment = .fill
		self.mainStack.axis = mainStackAxis
		self.mainStack.spacing = 30
		
		NSLayoutConstraint.activate([
			self.innerStack.heightAnchor.constraint(equalToConstant: 28),
			self.innerStack.leadingAnchor.constraint(equalTo: self.mainStack.leadingAnchor),
			self.innerStack.trailingAnchor.constraint(equalTo: self.mainStack.trailingAnchor),
			
			self.stepLabel.heightAnchor.constraint(equalToConstant: 44),
			self.nextStepPath.heightAnchor.constraint(equalToConstant: 1)
		])
		self.layoutIfNeeded()
	}
	
	func setIsFinal(_ isFinal: Bool) {
		self.isFinalElement = isFinal
		self.nextStepPath.backgroundColor = isFinalElement ? .clear: stepInactiveColor
	}
	
	var isDone: Bool = false {
		didSet {
			switch isDone {
				case true:
					self.checkCircle.image = stepShape == .circular ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.square.fill")
					self.checkCircle.tintColor = stepActiveColor
					self.nextStepPath.backgroundColor = isFinalElement ? .clear : stepActiveColor
					self.stepLabel.textColor = stepActiveColor
				case false:
					self.checkCircle.image = stepShape == .circular ? UIImage(systemName: "\(tag).circle.fill") : UIImage(systemName: "\(tag).square.fill")
					self.checkCircle.tintColor = isSelected ? stepActiveColor : stepInactiveColor
					self.nextStepPath.backgroundColor = isFinalElement ? .clear : isSelected ? stepActiveColor : stepInactiveColor
					self.stepLabel.textColor = isSelected ? stepActiveColor : .darkGray
			}
			DispatchQueue.main.async {
				self.nextStepPath.superview!.layoutIfNeeded()
			}
		}
	}
	
	var isSelected: Bool = false {
		didSet {
			switch isSelected {
				case true:
					checkCircle.tintColor = stepActiveColor
					stepLabel.textColor = stepActiveColor
				case false:
					checkCircle.tintColor = stepInactiveColor
					stepLabel.textColor = .darkGray
			}
			self.checkCircle.image = stepShape == .circular ? UIImage(systemName: "\(tag).circle.fill") : UIImage(systemName: "\(tag).sqquare.fill")
			self.nextStepPath.backgroundColor = isFinalElement ? .clear : stepInactiveColor
			DispatchQueue.main.async {
				self.nextStepPath.superview!.layoutIfNeeded()
			}
		}
	}
	
	func stepSelected() {
		self.isSelected = !isSelected
	}
	
	func stepChecked(_ state: StepState) {
		switch state {
			case .selected: isSelected = true
			case .done: isDone = true
			case .inactive:
				isSelected = false
				isDone = false
		}
	}
	
	enum StepState {
		case selected, done, inactive
	}
}

public enum StepShape {
	case circular, square
}
