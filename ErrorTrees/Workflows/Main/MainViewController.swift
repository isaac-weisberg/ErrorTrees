import RxSwift
import RxCocoa
import UIKit

class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: MainViewModel!
    
    @IBOutlet var requestForecast: UIButton!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var temperatureTitle: UILabel!
    @IBOutlet var bottomErrorContainer: UIView!
    @IBOutlet var bottomErrorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        requestForecast.rx.tap
            .bind(to: viewModel.forecastRequested)
            .disposed(by: disposeBag)

        viewModel.temperature
            .map { state -> String in
                switch state {
                case .unknown:
                    return "??°C"
                case .lastKnownTemperature(let temp), .temperature(let temp):
                    return "\(temp)°C"
                }
            }
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.temperature
            .map { state -> String in
                switch state {
                case .unknown:
                    return "Forecast unknown"
                case .temperature:
                    return "Forecast recieved"
                case .lastKnownTemperature:
                    return "There was an error downloading the forecast"
                }
            }
            .bind(to: temperatureTitle.rx.text)
            .disposed(by: disposeBag)

        viewModel.minorError
            .bind(onNext: { [unowned self] error in
                switch error {
                case .some(let error):
                    self.bottomErrorContainer.isHidden = false
                    self.bottomErrorLabel.text = error.errorSingular.singluarDescription
                case .none:
                    self.bottomErrorContainer.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
}
