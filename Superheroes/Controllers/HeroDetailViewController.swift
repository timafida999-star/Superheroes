import UIKit

final class HeroDetailViewController: UIViewController {

    var hero: Hero?

    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var publisherLabel: UILabel!

    @IBOutlet private weak var alignmentButton: UIButton!
    @IBOutlet private weak var totalPowerButton: UIButton!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var infoStackView: UIStackView!

    @IBOutlet private weak var statsCardView: UIView!
    @IBOutlet private weak var appearanceCardView: UIView!
    @IBOutlet private weak var bioCardView: UIView!

    @IBOutlet private weak var intelligenceValueLabel: UILabel!
    @IBOutlet private weak var strengthValueLabel: UILabel!
    @IBOutlet private weak var speedValueLabel: UILabel!
    @IBOutlet private weak var durabilityValueLabel: UILabel!
    @IBOutlet private weak var powerValueLabel: UILabel!
    @IBOutlet private weak var combatValueLabel: UILabel!

    @IBOutlet private weak var intelligenceBar: UIProgressView!
    @IBOutlet private weak var strengthBar: UIProgressView!
    @IBOutlet private weak var speedBar: UIProgressView!
    @IBOutlet private weak var durabilityBar: UIProgressView!
    @IBOutlet private weak var powerBar: UIProgressView!
    @IBOutlet private weak var combatBar: UIProgressView!

    @IBOutlet private weak var genderValueLabel: UILabel!
    @IBOutlet private weak var raceValueLabel: UILabel!
    @IBOutlet private weak var heightValueLabel: UILabel!
    @IBOutlet private weak var weightValueLabel: UILabel!
    @IBOutlet private weak var eyeColorValueLabel: UILabel!
    @IBOutlet private weak var hairColorValueLabel: UILabel!

    @IBOutlet private weak var fullNameValueLabel: UILabel!
    @IBOutlet private weak var placeOfBirthValueLabel: UILabel!
    @IBOutlet private weak var firstAppearanceValueLabel: UILabel!
    @IBOutlet private weak var occupationValueLabel: UILabel!

    private let gradientLayer = CAGradientLayer()
    private var accentColor: UIColor = .systemBlue
    private var isImageLoaded = false
    private var statBars: [(bar: UIProgressView, progress: Float)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupStyle()

        guard let hero else { return }
        accentColor = hero.alignment.color
        fillHeader(with: hero)
        fillStats(with: hero)
        fillAppearance(with: hero)
        fillBio(with: hero)
        setupChips(for: hero)
        setupSegmentedControl()
        loadImage(for: hero)
        showSection(0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = gradientView.bounds
        CATransaction.commit()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if segmentedControl.selectedSegmentIndex == 0 {
            animateStats()
        }
    }

    @IBAction private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        UIView.transition(with: infoStackView, duration: 0.25, options: .transitionCrossDissolve) {
            self.showSection(index)
        }
        if index == 0 {
            animateStats()
        }
    }

    @IBAction private func headerTapped(_ sender: UITapGestureRecognizer) {
        guard isImageLoaded else { return }
        let newMode: UIView.ContentMode = heroImageView.contentMode == .scaleAspectFill ? .scaleAspectFit : .scaleAspectFill
        UIView.transition(with: heroImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.heroImageView.contentMode = newMode
        }
    }

    private func setupStyle() {
        headerView.layer.cornerRadius = 24
        headerView.layer.cornerCurve = .continuous

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        let cards: [UIView] = [statsCardView, appearanceCardView, bioCardView]
        for card in cards {
            card.layer.cornerRadius = 18
            card.layer.cornerCurve = .continuous
        }
    }

    private func fillHeader(with hero: Hero) {
        nameLabel.text = hero.name
        publisherLabel.text = hero.biography.publisher
        publisherLabel.isHidden = Hero.isMissing(hero.biography.publisher)
    }

    private func fillStats(with hero: Hero) {
        let stats = hero.powerstats
        let rows: [(UILabel, UIProgressView, Int?)] = [
            (intelligenceValueLabel, intelligenceBar, stats.intelligence),
            (strengthValueLabel, strengthBar, stats.strength),
            (speedValueLabel, speedBar, stats.speed),
            (durabilityValueLabel, durabilityBar, stats.durability),
            (powerValueLabel, powerBar, stats.power),
            (combatValueLabel, combatBar, stats.combat)
        ]

        statBars = []
        for (label, bar, value) in rows {
            label.text = value.map { "\($0)" } ?? "Unknown"
            label.textColor = value == nil ? .secondaryLabel : .label
            bar.progressTintColor = accentColor
            bar.trackTintColor = accentColor.withAlphaComponent(0.15)
            bar.layer.cornerRadius = 4
            bar.clipsToBounds = true
            bar.setProgress(0, animated: false)

            let progress = Float(min(max(value ?? 0, 0), 100)) / 100
            statBars.append((bar: bar, progress: progress))
        }
    }

    private func fillAppearance(with hero: Hero) {
        let appearance = hero.appearance
        genderValueLabel.text = hero.gender == .unknown ? "Unknown" : hero.gender.title
        raceValueLabel.text = Hero.display(appearance.race)
        heightValueLabel.text = hero.heightText
        weightValueLabel.text = hero.weightText
        eyeColorValueLabel.text = Hero.display(appearance.eyeColor)
        hairColorValueLabel.text = Hero.display(appearance.hairColor)
    }

    private func fillBio(with hero: Hero) {
        fullNameValueLabel.text = Hero.display(hero.biography.fullName)
        placeOfBirthValueLabel.text = Hero.display(hero.biography.placeOfBirth)
        firstAppearanceValueLabel.text = Hero.display(hero.biography.firstAppearance)
        occupationValueLabel.text = Hero.display(hero.work.occupation)
    }

    private func setupChips(for hero: Hero) {
        let alignment = hero.alignment
        alignmentButton.configuration = makeChip(title: alignment.title, symbol: alignment.symbolName)

        let powerTitle = hero.totalPower > 0 ? "Total power \(hero.totalPower)" : "Power unknown"
        totalPowerButton.configuration = makeChip(title: powerTitle, symbol: "bolt.fill")
    }

    private func makeChip(title: String, symbol: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.buttonSize = .medium
        config.baseBackgroundColor = accentColor.withAlphaComponent(0.15)
        config.baseForegroundColor = accentColor
        config.image = UIImage(systemName: symbol)
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        config.imagePadding = 6
        config.title = title
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes
            updated.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return updated
        }
        return config
    }

    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentTintColor = accentColor
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    private func showSection(_ index: Int) {
        statsCardView.isHidden = index != 0
        appearanceCardView.isHidden = index != 1
        bioCardView.isHidden = index != 2
    }

    private func animateStats() {
        view.layoutIfNeeded()
        for (index, item) in statBars.enumerated() {
            let bar = item.bar
            let progress = item.progress
            bar.setProgress(0, animated: false)
            bar.layoutIfNeeded()

            UIView.animate(withDuration: 0.7, delay: 0.07 * Double(index), options: .curveEaseOut) {
                bar.setProgress(progress, animated: true)
                bar.layoutIfNeeded()
            }
        }
    }

    private func loadImage(for hero: Hero) {
        heroImageView.contentMode = .center
        heroImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .light)
        heroImageView.tintColor = .tertiaryLabel
        heroImageView.image = UIImage(systemName: "person.crop.rectangle")

        HeroService.shared.loadImage(from: hero.imageURL) { [weak self] image in
            guard let self, let image else { return }
            self.isImageLoaded = true
            UIView.transition(with: self.heroImageView, duration: 0.3, options: .transitionCrossDissolve) {
                self.heroImageView.contentMode = .scaleAspectFill
                self.heroImageView.image = image
            }
        }
    }
}
