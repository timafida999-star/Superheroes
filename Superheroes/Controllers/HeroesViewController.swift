import UIKit

final class HeroesViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var heroes: [Hero] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadHeroes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detailViewController = segue.destination as? HeroDetailViewController,
              let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }

        detailViewController.hero = heroes[indexPath.row]
    }

    private func loadHeroes() {
        activityIndicator.startAnimating()

        HeroService.shared.fetchHeroes { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let heroes):
                self.heroes = heroes
                self.tableView.reloadData()
            case .failure:
                self.showLoadingError()
            }
        }
    }

    private func showLoadingError() {
        let alert = UIAlertController(
            title: "Couldn't load heroes",
            message: "Check your internet connection and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadHeroes()
        })
        present(alert, animated: true)
    }
}

extension HeroesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeroCell.reuseIdentifier, for: indexPath) as? HeroCell else {
            return UITableViewCell()
        }
        cell.configure(with: heroes[indexPath.row])
        return cell
    }
}
