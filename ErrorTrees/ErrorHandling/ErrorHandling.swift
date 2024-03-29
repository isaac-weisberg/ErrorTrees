protocol ErrorSingularType {
    var singularDescription: String { get }
}

protocol ErrorSingularRepresentable {
    var errorSingular: ErrorSingularType { get }
}

extension String: ErrorSingularType {
    var singularDescription: String {
        return self
    }
}

protocol ErrorTitledSingularType {
    var title: String { get }

    var singularDescription: String { get }
}


struct ErrorTitledSingular: ErrorTitledSingularType {
    let title: String
    let singularDescription: String

    init(_ title: String, _ desc: String) {
        self.title = title
        self.singularDescription = desc
    }
}

protocol ErrorTitledSingularRepresentable {
    var errorTitledSingular: ErrorTitledSingularType { get }
}
