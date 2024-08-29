//
//  ViewController.swift
//  currency-converter
//
//  Created by Fernando Schulz on 27/07/24.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {
    
    var currencies: [Currency] = []
    private let tableView = UITableView()
    var isSelectingConvertCurrency = false
    
    private lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor(named: AssetsConstants.primaryColor)
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        return topView
    }()
    
    private lazy var bottomView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(named: AssetsConstants.secondaryColor)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        return bottomView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Cotação de Moedas"
        label.textColor = UIColor(named: AssetsConstants.secondaryColor)
        label.font = .systemFont(ofSize: 24, weight: .bold)
        
        return label
    }()
    
    private lazy var buttonConvert: UIButton = {
        let buttonConvert = UIButton(type: .system)
        buttonConvert.translatesAutoresizingMaskIntoConstraints = false
        buttonConvert.backgroundColor = UIColor(named: AssetsConstants.primaryColor)
        buttonConvert.layer.cornerRadius = 35
        buttonConvert.layer.masksToBounds = true
        if let originalImage = UIImage(systemName: "arrow.up.arrow.down") {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let largeImage = originalImage.applyingSymbolConfiguration(largeConfig)
            buttonConvert.setImage(largeImage, for: .normal)
        }
        buttonConvert.tintColor = UIColor(named: AssetsConstants.secondaryColor)
        buttonConvert.addTarget(self, action: #selector(convertButtonPressed), for: .touchUpInside)
        
        return buttonConvert
    }()
    
    private lazy var buttonPicker: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let originalImage = UIImage(systemName: "arrow.up.arrow.down") {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let largeImage = originalImage.applyingSymbolConfiguration(largeConfig)
            buttonConvert.setImage(largeImage, for: .normal)
        }
        buttonConvert.tintColor = UIColor(named: AssetsConstants.secondaryColor)
        
        return button
    }()
    
    private lazy var textFieldValue: PaddedTextField = {
        let textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: AssetsConstants.primaryColor)
        textField.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(named: AssetsConstants.secondaryColor)?.cgColor
        textField.layer.cornerRadius = 5.0
        textField.textColor = UIColor(named: AssetsConstants.secondaryColor)
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        
        return textField
    }()
    
    private lazy var textFieldConverted: PaddedTextField = {
        let textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: AssetsConstants.secondaryColor)
        textField.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(named: AssetsConstants.primaryColor)?.cgColor
        textField.layer.cornerRadius = 5.0
        textField.textColor = UIColor(named: AssetsConstants.primaryColor)
        textField.textAlignment = .right
        textField.isUserInteractionEnabled = false
        
        return textField
    }()
    
    private lazy var selectedCurrencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: AssetsConstants.secondaryColor)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currencyPickerTextFieldTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var selectedCurrencyFlagImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currencyPickerTextFieldTapped))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGesture)
        
        return image
    }()
    
    private lazy var buttonCurrency: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: AssetsConstants.primaryColor)
        if let originalImage = UIImage(systemName: "arrowtriangle.down.fill") {
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            let smallImage = originalImage.applyingSymbolConfiguration(smallConfig)
            button.setImage(smallImage, for: .normal)
        }
        button.tintColor = UIColor(named: AssetsConstants.secondaryColor)
        button.addTarget(self, action: #selector(currencyPickerTextFieldTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var selectedConvertLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: AssetsConstants.primaryColor)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currencyPickerTextFieldTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var selectedConvertFlagImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currencyPickerTextFieldTapped))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGesture)
        
        return image
    }()
    
    private lazy var buttonConverted: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: AssetsConstants.secondaryColor)
        if let originalImage = UIImage(systemName: "arrowtriangle.down.fill") {
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            let smallImage = originalImage.applyingSymbolConfiguration(smallConfig)
            button.setImage(smallImage, for: .normal)
        }
        button.tintColor = UIColor(named: AssetsConstants.primaryColor)
        button.addTarget(self, action: #selector(currencyPickerTextFieldTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    private lazy var currencyPickerTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.inputView = currencyPicker
        textField.inputAccessoryView = toolbar
        textField.isHidden = true
        textField.addTarget(self, action: #selector(currencyPickerTextFieldTapped), for: .touchDown)
        
        return textField
    }()
    
    private lazy var currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
        return picker
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupTableView()
        setupConstraints()
        buscaMoedas()
        
        tableView.reloadData()
    }
    
    private func buscaMoedas() {
        spinner.startAnimating()
        
        fetchCurrencies { [weak self] currencies, error in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                
                if let error = error {
                    print("Failed to fetch currencies: \(error)")
                    return
                }
                
                if let currencies = currencies {
                    self?.currencies = currencies
                    self?.tableView.reloadData()
                    
                    // Encontrar as moedas BRL e USD
                    var moedaOrigem: Currency?
                    var moedaDestino: Currency?
                    
                    for moeda in currencies {
                        if moeda.code == "BRL" {
                            moedaOrigem = moeda
                        } else if moeda.code == "USD" {
                            moedaDestino = moeda
                        }
                        
                        // Se ambas as moedas foram encontradas, podemos parar a busca
                        if moedaOrigem != nil && moedaDestino != nil {
                            break
                        }
                    }
                    
                    // Setar as labels e imagens
                    if let moedaOrigem = moedaOrigem {
                        self?.selectedCurrencyLabel.text = moedaOrigem.code
                        if let data = Data(base64Encoded: moedaOrigem.flag), let image = UIImage(data: data) {
                            self?.selectedCurrencyFlagImageView.image = image
                        }
                    }
                    
                    if let moedaDestino = moedaDestino {
                        self?.selectedConvertLabel.text = moedaDestino.code
                        if let data = Data(base64Encoded: moedaDestino.flag), let image = UIImage(data: data) {
                            self?.selectedConvertFlagImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    private func addSubViews() {
        view.addSubview(topView)
        view.addSubview(bottomView)
        view.addSubview(buttonConvert)
        view.addSubview(textFieldValue)
        view.addSubview(textFieldConverted)
        view.addSubview(selectedCurrencyLabel)
        view.addSubview(selectedCurrencyFlagImageView)
        view.addSubview(currencyPickerTextField)
        view.addSubview(buttonCurrency)
        view.addSubview(selectedConvertLabel)
        view.addSubview(buttonConverted)
        view.addSubview(selectedConvertFlagImageView)
        view.addSubview(spinner)
        topView.addSubview(label)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        view.backgroundColor = UIColor(named: AssetsConstants.secondaryColor)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //TopView
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            //BottomView
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //Button Convert
            buttonConvert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonConvert.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonConvert.widthAnchor.constraint(equalToConstant: 70),
            buttonConvert.heightAnchor.constraint(equalToConstant: 70),
            
            //Text Field Value
            textFieldValue.centerXAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerXAnchor),
            textFieldValue.centerYAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerYAnchor),
            textFieldValue.widthAnchor.constraint(equalToConstant: textFieldValue.frame.width),
            textFieldValue.heightAnchor.constraint(equalToConstant: textFieldValue.frame.height),
            
            //Text Field Value
            textFieldConverted.centerXAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.centerXAnchor),
            textFieldConverted.centerYAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.centerYAnchor),
            textFieldConverted.widthAnchor.constraint(equalToConstant: textFieldConverted.frame.width),
            textFieldConverted.heightAnchor.constraint(equalToConstant: textFieldConverted.frame.height),
            
            //Title
            label.topAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            
            currencyPickerTextField.centerXAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerXAnchor),
            currencyPickerTextField.centerYAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerYAnchor),
            currencyPickerTextField.widthAnchor.constraint(equalToConstant: 200),
            currencyPickerTextField.heightAnchor.constraint(equalToConstant: 40),
            
            selectedCurrencyFlagImageView.widthAnchor.constraint(equalToConstant: 20),
            selectedCurrencyFlagImageView.heightAnchor.constraint(equalToConstant: 20),
            selectedCurrencyFlagImageView.leadingAnchor.constraint(equalTo: textFieldValue.leadingAnchor, constant: 10),
            selectedCurrencyFlagImageView.centerYAnchor.constraint(equalTo: textFieldValue.centerYAnchor),
            
            selectedCurrencyLabel.leadingAnchor.constraint(equalTo: selectedCurrencyFlagImageView.trailingAnchor, constant: 5),
            selectedCurrencyLabel.centerYAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerYAnchor),
            
            buttonCurrency.widthAnchor.constraint(equalToConstant: 20),
            buttonCurrency.heightAnchor.constraint(equalToConstant: 20),
            buttonCurrency.leadingAnchor.constraint(equalTo: selectedCurrencyLabel.trailingAnchor),
            buttonCurrency.centerYAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.centerYAnchor),
            
            selectedConvertFlagImageView.widthAnchor.constraint(equalToConstant: 20),
            selectedConvertFlagImageView.heightAnchor.constraint(equalToConstant: 20),
            selectedConvertFlagImageView.leadingAnchor.constraint(equalTo: textFieldConverted.leadingAnchor, constant: 10),
            selectedConvertFlagImageView.centerYAnchor.constraint(equalTo: textFieldConverted.centerYAnchor),
            
            selectedConvertLabel.leadingAnchor.constraint(equalTo: selectedConvertFlagImageView.trailingAnchor, constant: 5),
            selectedConvertLabel.centerYAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.centerYAnchor),
            
            buttonConverted.widthAnchor.constraint(equalToConstant: 20),
            buttonConverted.heightAnchor.constraint(equalToConstant: 20),
            buttonConverted.leadingAnchor.constraint(equalTo: selectedConvertLabel.trailingAnchor),
            buttonConverted.centerYAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.centerYAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: textFieldValue.bottomAnchor, constant: 50),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCurvedMask()
    }
    
    private func applyCurvedMask() {
        let maskLayer = CAShapeLayer()
        let buttonRadius: CGFloat = 35
        let margin: CGFloat = 6
        let curveHeight = buttonRadius + margin
        let curveWidth = buttonRadius * 2 + margin * 2
        
        let path = UIBezierPath()
        let centerX = topView.bounds.width / 2
        let rect = CGRect(x: centerX - curveWidth / 2, y: topView.bounds.height - curveHeight, width: curveWidth, height: curveHeight)
        
        path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.maxY), radius: buttonRadius + margin, startAngle: .pi, endAngle: 0, clockwise: true)
        
        path.addLine(to: CGPoint(x: topView.bounds.width, y: topView.bounds.height))
        path.addLine(to: CGPoint(x: topView.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: topView.bounds.height))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.close()
        
        maskLayer.path = path.cgPath
        maskLayer.frame = topView.bounds
        
        topView.layer.mask = maskLayer
    }
    
    @objc func convertButtonPressed() {
        // Obter o texto do textFieldValue
        guard let text = textFieldValue.text, !text.isEmpty else {
            AlertService.showAlert(on: self, message: "O campo de valor não pode estar vazio.")
            return
        }
        
        // Converter texto para Double
        if let amount = Double(text.replacingOccurrences(of: ",", with: ".")) {
            // Chamar a função de conversão com o valor convertido
            spinner.startAnimating()
            convertCurrency(from: selectedCurrencyLabel.text ?? "BRL", to: selectedConvertLabel.text ?? "USD", amount: amount) { result, error in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    if let error = error {
                        print("Erro ao converter moeda: \(error.localizedDescription)")
                        AlertService.showAlert(on: self, message: "Erro ao converter moeda.")
                    } else if let result = result {
                        if let convertedValue = result["converted"] as? Double {
                            self.textFieldConverted.text = "\(formatNumber(convertedValue))"
                        } else {
                            self.textFieldConverted.text = "Conversão Falhou!"
                        }
                    }
                }
            }
        } else {
            AlertService.showAlert(on: self, message: "Digite um valor numérico válido.")
        }
    }
    
    @objc private func currencyPickerTextFieldTapped(sender: UITapGestureRecognizer) {
        if sender.view === selectedConvertLabel || sender.view === selectedConvertFlagImageView || sender.view === buttonConverted {
            isSelectingConvertCurrency = true
        } else {
            isSelectingConvertCurrency = false
        }
        
        currencyPickerTextField.becomeFirstResponder()
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
}

extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].code
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = currencies[row]
        
        if isSelectingConvertCurrency {
            selectedConvertLabel.text = selectedCurrency.code
            if let data = Data(base64Encoded: selectedCurrency.flag), let image = UIImage(data: data) {
                selectedConvertFlagImageView.image = image
            }
        } else {
            selectedCurrencyLabel.text = selectedCurrency.code
            if let data = Data(base64Encoded: selectedCurrency.flag), let image = UIImage(data: data) {
                selectedCurrencyFlagImageView.image = image
            }
        }
        
        textFieldValue.text = ""
        textFieldConverted.text = ""
        currencyPickerTextField.text = selectedCurrency.code
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currency = currencies[indexPath.row]
        cell.textLabel?.text = currency.name
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency = currencies[indexPath.row]
        selectedCurrencyLabel.text = selectedCurrency.code
        if let data = Data(base64Encoded: selectedCurrency.flag), let image = UIImage(data: data) {
            selectedCurrencyFlagImageView.image = image
        }
    }
}

