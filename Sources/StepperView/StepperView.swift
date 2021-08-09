//
//  StepperView.swift
//  AspenDental
//
//  Created by Dusan Juranovic on 23.7.21..
//

import UIKit
@objc public protocol StepperViewNavigationDelegate: AnyObject {
	func shouldNavigateToStep(_ step: StepView)
}

public protocol StepperViewStepDisplayable {
	var title: String {get set}
}

public class StepperView: UIView {
	private var stackView = UIStackView()
	public var axis: NSLayoutConstraint.Axis = .vertical {
		didSet {
			addConstraints()
		}
	}
	public var activeColor: UIColor = .blue
	public var inactiveColor: UIColor = .lightGray
	public var stepShape: StepShape = .circular
	
	private var steps: [StepView] = []
	public weak var delegate: StepperViewNavigationDelegate?
	
	private var currentlySelectedItemIndex: Int = 0
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	private func commonInit() {
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.distribution = .fillEqually
		self.stackView.alignment = .fill
		self.stackView.spacing = 9
		self.addSubview(self.stackView)
		addConstraints()
	}
	
	private func addConstraints() {
		switch axis {
			case .vertical:
				self.activateVerticalConstraints()
			case .horizontal:
				self.cleanupConstraints()
				self.activateHorizontalConstraints()
			default: break
		}
	}
	
	private func cleanupConstraints() {
		self.constraints.forEach {$0.isActive = false}
		self.stackView.constraints.forEach {$0.isActive = false}
	}
	
	private func activateVerticalConstraints() {
		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 72),
			self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 27),
			self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -13),
			self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -72)
		])
		self.layoutIfNeeded()
	}
	
	private func activateHorizontalConstraints() {
		
		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 27),
			self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 205),
			self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -72),
			self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13)
		])
		self.layoutIfNeeded()
	}
	
	public func loadSteps(_ steps: [StepperViewStepDisplayable?]) {
		self.stackView.axis = axis
		for i in 0..<steps.count {
			guard let step = steps[i] else {return}
			let item = createItem(step: step, tag: i+1)
			item.axis = axis
			self.steps.append(item)
			item.setIsFinal(i+1 == steps.count)
			self.stackView.addArrangedSubview(item)
		}
		self.currentlySelectedItemIndex = 0
		self.steps.first?.stepChecked(.selected)
		self.stackView.layoutIfNeeded()
	}
	
	private func createItem(step: StepperViewStepDisplayable, tag: Int) -> StepView {
		let step = StepView(title: step.title, tag: tag, activeColor: activeColor, inactiveColor: inactiveColor, shape: stepShape)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateTo))
		step.addGestureRecognizer(tapGesture)
		return step
	}
	
	@objc private func navigateTo(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? StepView else {return}
		self.delegate?.shouldNavigateToStep(view)
	}
	
	public func nextItem(_ completion: (Bool)->()) {
		self.updateSteps(.forward, completion)
	}
	
	public func previousItem(_ completion: (Bool)->()) {
		self.updateSteps(.back, completion)
	}
	
	public func setSelected(_ step: StepView) {
		for s in steps {
			s.isSelected = false
			if s == step {
				s.stepSelected()
				self.currentlySelectedItemIndex = s.tag
			}
		}
	}
	
	private func updateSteps(_ direction: StepDirection, _ completion:(Bool)->()) {
		let currentStepIndex = min(max(self.currentlySelectedItemIndex, 0), steps.count - 1)
		let currentItem = steps[currentStepIndex]
		var nextItem: StepView
		
		switch direction {
			case .forward:
				let clampedIndex = min(currentStepIndex + 1, steps.count - 1)
				nextItem = steps[clampedIndex]
				self.currentlySelectedItemIndex += 1
				if self.currentlySelectedItemIndex > steps.count - 1 {
					self.currentlySelectedItemIndex = steps.count - 1
				}
			case .back:
				let clampedIndex = max(currentStepIndex - 1, 0)
				nextItem = steps[clampedIndex]
				self.currentlySelectedItemIndex -= 1
				if self.currentlySelectedItemIndex < 0 {
					self.currentlySelectedItemIndex = 0
				}
		}
		
		if direction == .forward {
			guard !currentItem.isFinalElement else {
				currentItem.stepChecked(.done)
				completion(true)
				return
			}
		}
		
		self.delegate?.shouldNavigateToStep(nextItem)
		completion(currentItem.isFinalElement)
		switch direction {
			case .forward:
				currentItem.stepChecked(.done)
				nextItem.stepChecked(.selected)
			case .back:
				currentItem.stepChecked(.inactive)
				nextItem.stepChecked(.selected)
		}
	}
	
	enum StepDirection {
		case forward, back
	}
}
