import UIKit


struct Checkbox: Decodable {
    let id: String
    let title: String
}


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var controls: [[String: Any]] = []
    var pickerItems: [(name: String, url: String)] = []
    var activeTextField: UITextField?
    var pickerView: UIPickerView?
    
    private let horizontalMargin: CGFloat = 40
    private let verticalSpacing: CGFloat = 20
    
    var radioButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        loadControls(in: contentView)
    }
    
    func loadControls(in contentView: UIView) {
        if let path = Bundle.main.path(forResource: "controls", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    controls = jsonArray
                    setupControls(in: contentView)
                }
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
    }
    
    func setupControls(in contentView: UIView) {
        var yOffset: CGFloat = 100
        let contentWidth = view.frame.width - (2 * horizontalMargin)
        
        for control in controls {
            if let type = control["control"] as? String {
                switch type {
                case "label":
                    if let text = control["text"] as? String {
                        let label = UILabel(frame: CGRect(x: horizontalMargin, y: yOffset, width: contentWidth, height: 30))
                        label.text = text
                        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        
                        if let fontWeight = control["fontWeight"] as? String {
                            switch fontWeight {
                            case "bold":
                                label.font = UIFont.boldSystemFont(ofSize: 17)
                            case "italic":
                                label.font = UIFont.italicSystemFont(ofSize: 17)
                            default:
                                break
                            }
                        }
                        
                        if let alignment = control["alignment"] as? String {
                            switch alignment {
                            case "left":
                                label.textAlignment = .left
                            case "center":
                                label.textAlignment = .center
                            case "right":
                                label.textAlignment = .right
                            default:
                                break
                            }
                        }
                        
                        if let colorString = control["color"] as? String {
                            label.textColor = UIColor(hex: colorString)
                        }
                        
                        contentView.addSubview(label)
                        yOffset += 30 + verticalSpacing
                    }
                case "textbox":
                    let textField = UITextField(frame: CGRect(x: horizontalMargin, y: yOffset, width: contentWidth, height: 30))
                    textField.borderStyle = .roundedRect
                    
                    if let text = control["text"] as? String {
                        textField.text = text
                    }
                    
                    if let backgroundColorString = control["backgroundColor"] as? String {
                        textField.backgroundColor = UIColor(hex: backgroundColorString)
                    }
                    
                    if let textColorString = control["textColor"] as? String {
                        textField.textColor = UIColor(hex: textColorString)
                    }
                    
                    contentView.addSubview(textField)
                    yOffset += 30 + verticalSpacing
                case "picker":
                    if let items = control["items"] as? [[String: String]] {
                        for item in items {
                            if let name = item["name"], let url = item["url"] {
                                pickerItems.append((name: name, url: url))
                            }
                        }
                        
                        pickerView = UIPickerView()
                        pickerView?.delegate = self
                        pickerView?.dataSource = self
                        
                        if let pickerBackgroundColor = control["backgroundColor"] as? String {
                            pickerView?.backgroundColor = UIColor(hex: pickerBackgroundColor)
                        }
                        
                        let pickerTextField = UITextField(frame: CGRect(x: horizontalMargin, y: yOffset, width: contentWidth, height: 30))
                        pickerTextField.borderStyle = .roundedRect
                        pickerTextField.delegate = self
                        
                        if let placeholder = control["placeholder"] as? String {
                            pickerTextField.placeholder = placeholder
                        }
                        
                        if let backgroundColor = control["backgroundColor"] as? String {
                            pickerTextField.backgroundColor = UIColor(hex: backgroundColor)
                        }
                        
                        if let textColor = control["textColor"] as? String {
                            pickerTextField.textColor = UIColor(hex: textColor)
                        }
                        
                        if let fontDict = control["font"] as? [String: Any] {
                            var fontSize: CGFloat = 14
                            var fontWeight: UIFont.Weight = .regular
                            if let size = fontDict["size"] as? CGFloat {
                                fontSize = size
                            }
                            if let weightString = fontDict["weight"] as? String {
                                fontWeight = weightString == "bold" ? .bold : .regular
                            }
                            pickerTextField.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
                        }
                        
                        let toolbar = UIToolbar()
                        toolbar.sizeToFit()
                        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
                        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
                        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
                        
                        pickerTextField.inputView = pickerView
                        pickerTextField.inputAccessoryView = toolbar
                        
                        contentView.addSubview(pickerTextField)
                        yOffset += 30 + verticalSpacing
                    }
                case "image":
                    if let urlString = control["url"] as? String, let url = URL(string: urlString) {
                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFit
                        imageView.load(url: url)
                        contentView.addSubview(imageView)
                        
                        imageView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yOffset),
                            imageView.heightAnchor.constraint(equalToConstant: 200),
                            imageView.widthAnchor.constraint(equalToConstant: 300)
                        ])
                        
                        yOffset += 200 + verticalSpacing
                    }
                case "button":
                    if let buttonText = control["text"] as? String {
                        let button = UIButton(type: .system)
                        button.setTitle(buttonText, for: .normal)
                        
                        
                        var configuration = UIButton.Configuration.filled()
                        configuration.title = buttonText
                        configuration.titlePadding = 10
                        button.configuration = configuration
                        
                        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                        contentView.addSubview(button)
                        
                        button.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yOffset),
                            button.heightAnchor.constraint(equalToConstant: 40),
                            button.widthAnchor.constraint(equalToConstant: 200)
                        ])
                        
                        yOffset += 40 + verticalSpacing
                    }
                case "radio":
                    if let items = control["items"] as? [[String: String]] {
                        let stackView = UIStackView(frame: CGRect(x: horizontalMargin, y: yOffset, width: contentWidth, height: CGFloat(items.count * 30)))
                        stackView.axis = .vertical
                        stackView.alignment = .leading
                        stackView.distribution = .equalSpacing
                        stackView.spacing = 10
                        
                        radioButtons.removeAll()
                        for item in items {
                            if let title = item["title"] {
                                let button = UIButton(type: .custom)
                                button.setTitle(title, for: .normal)
                                button.setTitleColor(.black, for: .normal)
                                button.setImage(UIImage(systemName: "circle"), for: .normal)
                                button.setImage(UIImage(systemName: "circle.inset.filled"), for: .selected)
                                button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
                                button.contentHorizontalAlignment = .left
                                
                                radioButtons.append(button)
                                stackView.addArrangedSubview(button)
                            }
                        }
                        
                        contentView.addSubview(stackView)
                        yOffset += stackView.frame.height + verticalSpacing
                    }
                case "checkboxes":
                    if let checkboxesData = control["checkboxes"] as? [[String: String]] {
                        let stackView = UIStackView(frame: CGRect(x: horizontalMargin, y: yOffset, width: contentWidth, height: CGFloat(checkboxesData.count * 30)))
                        stackView.axis = .vertical
                        stackView.alignment = .leading
                        stackView.distribution = .equalSpacing
                        stackView.spacing = 10
                        
                        for checkbox in checkboxesData {
                            if let id = checkbox["id"], let title = checkbox["title"] {
                                let checkboxButton = UIButton(type: .custom)
                                checkboxButton.setTitle(title, for: .normal)
                                checkboxButton.setTitleColor(.black, for: .normal)
                                checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
                                checkboxButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
                                checkboxButton.addTarget(self, action: #selector(checkboxToggled(_:)), for: .touchUpInside)
                                checkboxButton.contentHorizontalAlignment = .left
                                
                                stackView.addArrangedSubview(checkboxButton)
                            }
                        }
                        
                        contentView.addSubview(stackView)
                        yOffset += stackView.frame.height + verticalSpacing
                    }
                default:
                    break
                }
            }
        }
        
        contentView.heightAnchor.constraint(equalToConstant: yOffset).isActive = true
    }
    
    @objc func checkboxToggled(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @objc func radioButtonTapped(_ sender: UIButton) {
        radioButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
    }
    
    @objc func buttonAction() {
        if let selectedText = activeTextField?.text {
            openURLForSong(named: selectedText)
        }
    }
    
    @objc func cancelAction() {
        print("Cancel button tapped")
        activeTextField?.resignFirstResponder()
    }
    
    func openURLForSong(named songName: String) {
        if let url = pickerItems.first(where: { $0.name == songName })?.url, let songURL = URL(string: url) {
            UIApplication.shared.open(songURL)
        }
    }
    
    @objc func doneAction() {
        if let pickerView = activeTextField?.inputView as? UIPickerView {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedSong = pickerItems[selectedRow]
            activeTextField?.text = selectedSong.name
            
            if let url = URL(string: selectedSong.url) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Cannot open URL: \(url)")
                }
            }
        }
        activeTextField?.resignFirstResponder()
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeTextField?.text = pickerItems[row].name
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}


extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
    }
}

