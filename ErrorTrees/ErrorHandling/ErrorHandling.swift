protocol ErrorSingularType {
    var singluarDescription: String { get }
}

protocol ErrorSinglularRepresentable {
    var errorSingular: ErrorSingularType { get }
}

extension String: ErrorSingularType {
    var singluarDescription: String {
        return self
    }
}
