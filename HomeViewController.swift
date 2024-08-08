//
//  ViewController.swift
//  currency-converter
//
//  Created by Fernando Schulz on 27/07/24.
//

import UIKit
import Foundation

extension UIImageView {
    func setBase64Image(_ base64String: String) {
        guard let imageData = Data(base64Encoded: base64String) else {
            print("Erro: Falha ao converter string base64 para Data")
            return
        }
        guard let image = UIImage(data: imageData) else {
            print("Erro: Falha ao converter Data para UIImage")
            return
        }
        self.image = image
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
        currencyPickerTextField.text = selectedCurrency.code
        selectedCurrencyLabel.text = selectedCurrency.code
        if let data = Data(base64Encoded: selectedCurrency.flag), let image = UIImage(data: data) {
            selectedCurrencyFlagImageView.image = image
        }
    }
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct Currency: Codable {
        let code: String
        let name: String
        let flag: String
    }
    
    var currencies: [Currency] = []
    private let tableView = UITableView()
    
    //FUNCTIONS
    func convertCurrency(from: String, to: String, amount: Double, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let url = URL(string: "http://localhost:3210/convert") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["fromCurrency": from, "toCurrency": to, "amount": amount]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados não encontrados"]))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Formato de resposta inválido"]))
                }
            } catch let parseError {
                completion(nil, parseError)
            }
        }
        
        task.resume()
    }
    
    func fetchCurrencies(completion: @escaping ([Currency]?, Error?) -> Void) {
        let urlString = "http://localhost:3210/currencies"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No Data", code: 0, userInfo: nil))
                return
            }
            
            do {
                let currencies = try JSONDecoder().decode([Currency].self, from: data)
                completion(currencies, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR") // Configura para o formato brasileiro
        formatter.currencySymbol = "" // Remove o símbolo da moeda, se necessário
        formatter.groupingSeparator = "." // Separador de milhar
        formatter.decimalSeparator = "," // Separador decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    //VIEW
    
    private lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor(named: "PrimaryColor")
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        return topView
    }()
    
    private lazy var bottomView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(named: "SecondaryColor")
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        return bottomView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Cotação de Moedas"
        label.textColor = UIColor(named: "TextColor")
        label.font = .systemFont(ofSize: 24, weight: .bold)
        
        return label
    }()
    
    private lazy var buttonConvert: UIButton = {
        let buttonConvert = UIButton(type: .system)
        buttonConvert.translatesAutoresizingMaskIntoConstraints = false
        buttonConvert.backgroundColor = UIColor(named: "PrimaryColor")
        buttonConvert.layer.cornerRadius = 35
        buttonConvert.layer.masksToBounds = true
        if let originalImage = UIImage(systemName: "arrow.up.arrow.down") {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let largeImage = originalImage.applyingSymbolConfiguration(largeConfig)
            buttonConvert.setImage(largeImage, for: .normal)
        }
        buttonConvert.tintColor = UIColor(named: "SecondaryColor")
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
        buttonConvert.tintColor = UIColor(named: "SecondaryColor")
        
        return button
    }()
    
    private lazy var textFieldValue: PaddedTextField = {
        let textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "PrimaryColor")
        textField.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(named: "SecondaryColor")?.cgColor
        textField.layer.cornerRadius = 5.0
        textField.textColor = UIColor(named: "SecondaryColor")
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        
        return textField
    }()
    
    private lazy var textFieldConverted: PaddedTextField = {
        let textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "SecondaryColor")
        textField.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(named: "PrimaryColor")?.cgColor
        textField.layer.cornerRadius = 5.0
        textField.textColor = UIColor(named: "PrimaryColor")
        textField.textAlignment = .right
        textField.isUserInteractionEnabled = false
        
        return textField
    }()
    
    private lazy var selectedCurrencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "SecondaryColor")
        
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
        button.backgroundColor = UIColor(named: "PrimaryColor")
        if let originalImage = UIImage(systemName: "arrowtriangle.down.fill") {
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            let smallImage = originalImage.applyingSymbolConfiguration(smallConfig)
            button.setImage(smallImage, for: .normal)
        }
        button.tintColor = UIColor(named: "SecondaryColor")
        button.addTarget(self, action: #selector(currencyPickerTextFieldTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var selectedConvertLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "PrimaryColor")
        
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
        button.backgroundColor = UIColor(named: "SecondaryColor")
        if let originalImage = UIImage(systemName: "arrowtriangle.down.fill") {
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            let smallImage = originalImage.applyingSymbolConfiguration(smallConfig)
            button.setImage(smallImage, for: .normal)
        }
        button.tintColor = UIColor(named: "PrimaryColor")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupTableView()
        setupConstraints()
        buscaMoedas()
        
        tableView.reloadData()
    }
    
    private func buscaMoedas() {
        fetchCurrencies { [weak self] currencies, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch currencies: \(error)")
                    return
                }
                
                if let currencies = currencies {
                    self?.currencies = currencies
                    self?.tableView.reloadData()
                    
                    // Definir a moeda padrão como a primeira da lista
                    if let firstCurrency = currencies.first {
                        self?.selectedCurrencyLabel.text = firstCurrency.code
                        if let data = Data(base64Encoded: firstCurrency.flag), let image = UIImage(data: data) {
                            self?.selectedCurrencyFlagImageView.image = image
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
        topView.addSubview(label)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        view.backgroundColor = UIColor(named: "SecondaryColor")
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
        
        // Desenhar o arco na parte inferior da topView, projetando para cima
        path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.maxY), radius: buttonRadius + margin, startAngle: .pi, endAngle: 0, clockwise: true)
        
        // Desenhar linhas retas para fechar o caminho na área inferior da topView
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
    
    @objc func convertButtonPressed() {
        // Obter o texto do textFieldValue
        guard let text = textFieldValue.text, !text.isEmpty else {
            showAlert(message: "O campo de valor não pode estar vazio.")
            return
        }
        
        // Converter texto para Double
        if let amount = Double(text.replacingOccurrences(of: ",", with: ".")) {
            // Chamar a função de conversão com o valor convertido
            convertCurrency(from: "USD", to: "BRL", amount: amount) { result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Erro ao converter moeda: \(error.localizedDescription)")
                        self.showAlert(message: "Erro ao converter moeda.")
                    } else if let result = result {
                        print("Resultado da conversão: \(result)")
                        if let convertedValue = result["converted"] as? Double {
                            self.textFieldConverted.text = "\(self.formatNumber(convertedValue))"
                        } else {
                            self.textFieldConverted.text = "Conversão Falhou!"
                        }
                    }
                }
            }
        } else {
            // Mostrar alerta se a conversão falhar
            showAlert(message: "Digite um valor numérico válido.")
        }
    }
    
    @objc private func currencyPickerTextFieldTapped() {
        currencyPickerTextField.becomeFirstResponder()
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

