//
//  ViewController.swift
//  Cosmo
//
//  Created by Stuart Wallace on 4/25/22.
//

import UIKit

class ViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Task>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Task>
    let viewModel = ViewModel()
    private lazy var dataSource = makeDataSource()
    var collectionView = CollectionView.make()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        applySnapshot(animatingDifferences: false)
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(viewModel.sections)
        viewModel.sections.forEach { snapshot.appendItems($0.tasks, toSection: $0) }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func makeDataSource() -> DataSource {
        let cellProvider: UICollectionViewDiffableDataSourceReferenceCellProvider = { (collectionView, indexPath, task) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let config = BasicTaskCellConfig(text: self.viewModel.sections[indexPath.section].tasks[indexPath.row].id.uuidString)
            cell.contentConfiguration = config
            return cell
        }
        return DataSource(collectionView: collectionView, cellProvider: cellProvider)
    }
}

struct BasicTaskCellConfig : UIContentConfiguration {
    var text: String?
    func makeContentView() -> UIView & UIContentView { MyContentView(self) }
    func updated(for state: UIConfigurationState) -> BasicTaskCellConfig { self }
}

class MyContentView : UIView, UIContentView {
    
    let label = UILabel()
    var configuration: UIContentConfiguration {
        didSet { self.configure(configuration: configuration) }
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame:.zero)
        self.addSubview(self.label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
        ])
        self.configure(configuration: configuration)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? BasicTaskCellConfig else { return }
        self.label.text = configuration.text
    }
}

class Section: Hashable {
    let id = UUID()
    static func == (lhs: Section, rhs: Section) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    var tasks = [Task(), Task(), Task()]
}

class Task: Hashable {
    let id = UUID()
    static func == (lhs: Task, rhs: Task) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
