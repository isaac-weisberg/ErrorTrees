import RxSwift
import RxCocoa
import UIKit

class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: MainViewModel!
    
    @IBOutlet var requestForecast: UIButton!
    @IBOutlet var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestForecast.rx.tap
            .bind(to: viewModel.forecastRequested)
            .disposed(by: disposeBag)
    }
}
