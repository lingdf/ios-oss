import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48
  }
}

internal protocol ProjectPamphletMainCellDelegate: VideoViewControllerDelegate {
  func projectPamphletMainCell(_ cell: ProjectPamphletMainCell, addChildController child: UIViewController)
  func projectPamphletMainCell(
    _ cell: ProjectPamphletMainCell,
    goToCampaignForProjectWith projectAndRefTag: (project: Project, refTag: RefTag?)
  )
  func projectPamphletMainCell(_ cell: ProjectPamphletMainCell, goToCreatorForProject project: Project)
}

internal final class ProjectPamphletMainCell: UITableViewCell, ValueCell {
  internal weak var delegate: ProjectPamphletMainCellDelegate? {
    didSet {
      self.viewModel.inputs.delegateDidSet()
    }
  }

  fileprivate let viewModel: ProjectPamphletMainCellViewModelType = ProjectPamphletMainCellViewModel()

  fileprivate weak var videoController: VideoViewController?

  private lazy var creatorBylineView: CreatorBylineView = {
    CreatorBylineView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  @IBOutlet fileprivate var backersSubtitleLabel: UILabel!
  @IBOutlet fileprivate var backersTitleLabel: UILabel!
  @IBOutlet fileprivate var blurbAndReadMoreStackView: UIStackView!
  @IBOutlet fileprivate var categoryStackView: UIStackView!
  @IBOutlet fileprivate var categoryAndLocationStackView: UIStackView!
  @IBOutlet fileprivate var categoryIconImageView: UIImageView!
  @IBOutlet fileprivate var categoryNameLabel: UILabel!
  @IBOutlet fileprivate var contentStackView: UIStackView!
  @IBOutlet fileprivate var conversionLabel: UILabel!
  @IBOutlet fileprivate var creatorButton: UIButton!
  @IBOutlet fileprivate var creatorImageView: UIImageView!
  @IBOutlet fileprivate var creatorLabel: UILabel!
  @IBOutlet fileprivate var creatorStackView: UIStackView!
  @IBOutlet fileprivate var deadlineSubtitleLabel: UILabel!
  @IBOutlet fileprivate var deadlineTitleLabel: UILabel!
  @IBOutlet fileprivate var fundingProgressBarView: UIView!
  @IBOutlet fileprivate var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate var locationImageView: UIImageView!
  @IBOutlet fileprivate var locationNameLabel: UILabel!
  @IBOutlet fileprivate var locationStackView: UIStackView!
  @IBOutlet fileprivate var pledgeSubtitleLabel: UILabel!
  @IBOutlet fileprivate var pledgedTitleLabel: UILabel!
  @IBOutlet fileprivate var projectBlurbLabel: UILabel!
  @IBOutlet fileprivate var projectImageContainerView: UIView!
  @IBOutlet fileprivate var projectNameAndCreatorStackView: UIStackView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var progressBarAndStatsStackView: UIStackView!
  @IBOutlet fileprivate var readMoreButton: LoadingButton!
  @IBOutlet fileprivate var spacerView: UIView!
  @IBOutlet fileprivate var stateLabel: UILabel!
  @IBOutlet fileprivate var statsStackView: UIStackView!
  @IBOutlet fileprivate var youreABackerContainerView: UIView!
  @IBOutlet fileprivate var youreABackerLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.creatorButton.addTarget(
      self,
      action: #selector(self.creatorButtonTapped),
      for: .touchUpInside
    )
    self.readMoreButton.addTarget(
      self,
      action: #selector(self.readMoreButtonTapped),
      for: .touchUpInside
    )

    self.readMoreButton.heightAnchor
      .constraint(greaterThanOrEqualToConstant: Layout.Button.height).isActive = true

    self.viewModel.inputs.awakeFromNib()
  }

  internal func configureWith(value: (Project, RefTag?)) {
    _ = ([self.creatorBylineView], self.projectNameAndCreatorStackView)
      |> ksr_addArrangedSubviewsToStackView()

    // todo: removing this
    _ = self.creatorBylineView
      |> \.isHidden .~ true

//    _ = self.creatorStackView
//      |> \.isHidden .~ true

    self.viewModel.inputs.configureWith(value: value)
  }

  internal func scrollContentOffset(_ offset: CGFloat) {
    let height = self.projectImageContainerView.bounds.height
    let translation = offset / 2

    let scale: CGFloat
    if offset < 0 {
      scale = (height + abs(offset)) / height
    } else {
      scale = max(1, 1 - 0.5 * offset / height)
    }

    self.projectImageContainerView.transform = CGAffineTransform(
      a: scale, b: 0,
      c: 0, d: scale,
      tx: 0, ty: translation
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.clipsToBounds .~ true
      |> UITableViewCell.lens.accessibilityElements .~ self.subviews

    let subtitleLabelStyling = UILabel.lens.font .~ .ksr_caption1(size: 13)
      <> UILabel.lens.numberOfLines .~ 1
      <> UILabel.lens.backgroundColor .~ .white

    _ = [self.backersSubtitleLabel, self.deadlineSubtitleLabel]
      ||> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      ||> subtitleLabelStyling

    _ = self.pledgeSubtitleLabel |> subtitleLabelStyling

    _ = [self.backersTitleLabel, self.deadlineTitleLabel, self.pledgedTitleLabel]
      ||> UILabel.lens.font .~ .ksr_headline(size: 13)
      ||> UILabel.lens.numberOfLines .~ 1
      ||> UILabel.lens.backgroundColor .~ .white

    _ = self.categoryStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.categoryAndLocationStackView
      |> UIStackView.lens.layoutMargins .~ .init(top: 0, left: 0, bottom: Styles.grid(1), right: 0)

    _ = self.categoryIconImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_500
      |> UIImageView.lens.image .~ UIImage(named: "category-icon")
      |> UIImageView.lens.backgroundColor .~ .white

    _ = self.categoryNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font .~ .ksr_body(size: 12)
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.contentStackView
      |> UIStackView.lens.layoutMargins %~~ { _, stackView in
        stackView.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(top: Styles.grid(4), left: Styles.grid(4), bottom: Styles.grid(3), right: Styles.grid(4))
      }
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    _ = self.conversionLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ UIFont.ksr_caption2().italicized
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.creatorImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.creatorButton
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_creator_profile() }

    _ = self.creatorImageView
      |> UIImageView.lens.clipsToBounds .~ true
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.creatorLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.creatorStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    _ = self.locationImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_500
      |> UIImageView.lens.image .~ UIImage(named: "location-icon")
      |> UIImageView.lens.backgroundColor .~ .white

    _ = self.locationNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font .~ .ksr_body(size: 12)
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.locationStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.projectBlurbLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_body(size: 18)
          : .ksr_body(size: 15)
      }
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.projectNameAndCreatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.projectNameLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? .ksr_title3(size: 28)
          : .ksr_title3(size: 20)
      }
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.progressBarAndStatsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.stateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.statsStackView
      |> UIStackView.lens.isAccessibilityElement .~ true
      |> UIStackView.lens.backgroundColor .~ .white

    _ = self.youreABackerContainerView
      |> roundedStyle(cornerRadius: 2)
      |> UIView.lens.backgroundColor .~ .ksr_green_500
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.gridHalf(3))

    _ = self.youreABackerLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.text %~ { _ in Strings.Youre_a_backer() }

    _ = self.readMoreButton
      |> \.activityIndicatorStyle .~ .gray
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backersSubtitleLabel.rac.text = self.viewModel.outputs.backersSubtitleLabelText
    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersTitleLabelText
    self.backersTitleLabel.rac.textColor = self.viewModel.outputs.projectUnsuccessfulLabelTextColor
    self.categoryNameLabel.rac.text = self.viewModel.outputs.categoryNameLabelText
    self.conversionLabel.rac.hidden = self.viewModel.outputs.conversionLabelHidden
    self.conversionLabel.rac.text = self.viewModel.outputs.conversionLabelText
    self.creatorButton.rac.accessibilityLabel = self.viewModel.outputs.creatorLabelText
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.deadlineTitleLabel.rac.textColor = self.viewModel.outputs.projectUnsuccessfulLabelTextColor
    self.fundingProgressBarView.rac.backgroundColor =
      self.viewModel.outputs.fundingProgressBarViewBackgroundColor
    self.locationNameLabel.rac.text = self.viewModel.outputs.locationNameLabelText
    self.pledgeSubtitleLabel.rac.text = self.viewModel.outputs.pledgedSubtitleLabelText
    self.pledgeSubtitleLabel.rac.textColor = self.viewModel.outputs.pledgedTitleLabelTextColor
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedTitleLabelText
    self.pledgedTitleLabel.rac.textColor = self.viewModel.outputs.pledgedTitleLabelTextColor
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.readMoreButton.rac.title = self.viewModel.outputs.readMoreButtonTitle
    self.spacerView.rac.hidden = self.viewModel.outputs.spacerViewHidden
    self.stateLabel.rac.text = self.viewModel.outputs.projectStateLabelText
    self.stateLabel.rac.textColor = self.viewModel.outputs.projectStateLabelTextColor
    self.stateLabel.rac.hidden = self.viewModel.outputs.stateLabelHidden
    self.statsStackView.rac.accessibilityLabel = self.viewModel.outputs.statsStackViewAccessibilityLabel
    self.youreABackerContainerView.rac.hidden = self.viewModel.outputs.youreABackerLabelHidden

    self.viewModel.outputs.readMoreButtonIsLoading
      .observeForUI()
      .observeValues { [weak self] isLoading in
        self?.readMoreButton.isLoading = isLoading
      }

    self.viewModel.outputs.configureVideoPlayerController
      .observeForUI()
      .observeValues { [weak self] in self?.configureVideoPlayerController(forProject: $0) }

    self.viewModel.outputs.configureCreatorBylineView
      .observeForUI()
      .observeValues { [weak self] in self?.creatorBylineView.configureWith(value: $0) }

    self.viewModel.outputs.creatorImageUrl
      .observeForUI()
      .on(event: { [weak self] _ in self?.creatorImageView.image = nil })
      .skipNil()
      .observeValues { [weak self] in self?.creatorImageView.af_setImage(withURL: $0) }

    self.viewModel.outputs.notifyDelegateToGoToCampaignWithProjectAndRefTag
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.projectPamphletMainCell(self, goToCampaignForProjectWith: $0)
      }

    self.viewModel.outputs.readMoreButtonStyle
      .observeForUI()
      .observeValues { [weak self] buttonStyleType in
        _ = self?.readMoreButton
          ?|> buttonStyleType.style
      }

    self.viewModel.outputs.blurbAndReadMoreStackViewSpacing
      .observeForUI()
      .observeValues { [weak self] spacing in
        self?.blurbAndReadMoreStackView.spacing = spacing
      }

    self.viewModel.outputs.notifyDelegateToGoToCreator
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.projectPamphletMainCell(self, goToCreatorForProject: $0)
      }

    self.viewModel.outputs.opacityForViews
      .observeForUI()
      .observeValues { [weak self] alpha in
        guard let self = self else { return }
        UIView.animate(
          withDuration: alpha == 0.0 ? 0.0 : 0.3,
          delay: 0.0,
          options: .curveEaseOut,
          animations: {
            self.creatorStackView.alpha = alpha
            self.statsStackView.alpha = alpha
            self.blurbAndReadMoreStackView.alpha = alpha
          },
          completion: nil
        )
      }

    self.viewModel.outputs.progressPercentage
      .observeForUI()
      .observeValues { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransform(scaleX: CGFloat(progress), y: 1.0)
      }
  }

  fileprivate func configureVideoPlayerController(forProject project: Project) {
    let vc = VideoViewController.configuredWith(project: project)
    vc.delegate = self
    vc.view.translatesAutoresizingMaskIntoConstraints = false
    self.projectImageContainerView.addSubview(vc.view)

    NSLayoutConstraint.activate([
      vc.view.topAnchor.constraint(equalTo: self.projectImageContainerView.topAnchor),
      vc.view.leadingAnchor.constraint(equalTo: self.projectImageContainerView.leadingAnchor),
      vc.view.bottomAnchor.constraint(equalTo: self.projectImageContainerView.bottomAnchor),
      vc.view.trailingAnchor.constraint(equalTo: self.projectImageContainerView.trailingAnchor)
    ])

    self.delegate?.projectPamphletMainCell(self, addChildController: vc)
    self.videoController = vc
  }

  @objc fileprivate func readMoreButtonTapped() {
    self.viewModel.inputs.readMoreButtonTapped()
  }

  @objc fileprivate func creatorButtonTapped() {
    self.viewModel.inputs.creatorButtonTapped()
  }
}

extension ProjectPamphletMainCell: VideoViewControllerDelegate {
  internal func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.delegate?.videoViewControllerDidFinish(controller)
    self.viewModel.inputs.videoDidFinish()
  }

  internal func videoViewControllerDidStart(_ controller: VideoViewController) {
    self.delegate?.videoViewControllerDidStart(controller)
    self.viewModel.inputs.videoDidStart()
  }
}
