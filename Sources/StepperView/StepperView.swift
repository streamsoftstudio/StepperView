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
		let step = StepView(title: step.title, tag: tag, activeColor: self.activeColor, inactiveColor: inactiveColor)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateTo))
		step.addGestureRecognizer(tapGesture)
		return step
	}
	
	@objc private func navigateTo(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? StepView else {return}
		print("Navigate to ", view.stepTitle)
		self.delegate?.shouldNavigateToStep(view)
	}
	
	public func nextItem(_ completion: (Int, Bool, Bool)->()) {
		self.updateSteps(.forward, completion)
	}
	
	public func previousItem(_ completion: (Int, Bool, Bool)->()) {
		self.updateSteps(.back, completion)
	}
	
	public func setSelected(_ step: StepView) {
		for s in steps {
			s.isSelected = false
			if s == step {
				s.stepSelected()
			}
		}
	}
	
	private func updateSteps(_ direction: StepDirection, _ completion:(Int, Bool, Bool)->()) {
		switch direction {
			case .forward: self.currentlySelectedItemIndex += 1
			case .back: self.currentlySelectedItemIndex -= 1
		}
		let tag = self.currentlySelectedItemIndex
		
		guard tag < steps.count else {
			steps.last?.stepChecked(.done)
			completion(tag, false, steps.last!.isFinalElement)
			return
		}
		guard tag >= 0 else {return}
		
		let nextStepTag = tag + 1
		let prevStepTag = tag - 1
		switch direction {
			case .forward: completion(nextStepTag, nextStepTag == steps.count, false)
			case .back: completion(prevStepTag, prevStepTag == steps.count, false)
		}
		
		self.delegate?.shouldNavigateToStep(steps[tag])
		
		let currentStep = steps[tag]
		let previousStep = steps[prevStepTag]
		
		switch direction {
			case .forward:
				previousStep.stepChecked(.done)
				currentStep.stepChecked(.selected)
			case .back:
				previousStep.stepChecked(.selected)
				currentStep.stepChecked(.inactive)
		}
	}
	
	enum StepDirection {
		case forward, back
	}
}
