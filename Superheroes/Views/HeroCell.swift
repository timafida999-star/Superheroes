import UIKit

final class HeroCell: UITableViewCell {

    static let reuseIdentifier = "HeroCell"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var genderBadgeView: UIView!
    @IBOutlet private weak var genderImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        cardView.layer.cornerRadius = 16
        cardView.layer.cornerCurve = .continuous
        genderBadgeView.layer.cornerRadius = 20
        chevronImageView.image = UIImage(systemName: "chevron.right")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        genderImageView.image = nil
        cardView.transform = .identity
    }

    func configure(with hero: Hero) {
        let gender = hero.gender
        nameLabel.text = hero.name
        genderImageView.image = UIImage(systemName: gender.symbolName) ?? UIImage(systemName: "person.fill")
        genderImageView.tintColor = gender.color
        genderBadgeView.backgroundColor = gender.color.withAlphaComponent(0.15)
        genderImageView.accessibilityLabel = gender.title
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard cardView != nil else { return }

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.cardView.backgroundColor = highlighted ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
        }
    }
}
