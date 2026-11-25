import UIKit

nonisolated enum HeroServiceError: Error {
    case invalidURL
    case badResponse
    case noData
}

final class HeroService {

    static let shared = HeroService()

    private let allHeroesURL = "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json"

    private init() {}

    func fetchHeroes(completion: @escaping @MainActor (Result<[Hero], Error>) -> Void) {
        guard let url = URL(string: allHeroesURL) else {
            completion(.failure(HeroServiceError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(HeroServiceError.badResponse))
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(HeroServiceError.noData))
                }
                return
            }

            do {
                let heroes = try JSONDecoder().decode([Hero].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(heroes))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func loadImage(from urlString: String?, completion: @escaping @MainActor (UIImage?) -> Void) {
        guard let urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                guard let data else {
                    completion(nil)
                    return
                }
                completion(UIImage(data: data))
            }
        }.resume()
    }
}
