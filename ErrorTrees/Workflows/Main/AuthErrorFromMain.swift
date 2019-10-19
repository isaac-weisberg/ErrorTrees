import UIKit

struct AuthErrorFromMain: AuthErrorModelRepresentable {
    var authErrorModel: AuthErrorModelType {
        return AuthErrorModel(
            title: "Authorization issue",
            description: "You have tried to get a forecast, but it seems that you aren't logged in",
            image: [
                "timmyb",
                "idupes",
                "conniptions"
            ]
            .map { name in
                UIImage(named: name)!
            }
            .randomElement()!
        )
    }
}
