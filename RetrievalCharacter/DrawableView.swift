import UIKit

class DrawableView: UIView {
    private var drawLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.cyan.cgColor
        layer.lineWidth = 4
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()

    private var beziPath: UIBezierPath!

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(drawLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 计算中间点
    private func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let currentPoint = touch?.location(in: self) else { return }
        beziPath = UIBezierPath()
        beziPath.move(to: currentPoint)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let currentPoint = touch?.location(in: self) else { return }
        guard let prePoint = touch?.previousLocation(in: self) else { return }
        let midPoint = midPoint(p1: prePoint, p2: currentPoint)
        beziPath.addQuadCurve(to: currentPoint, controlPoint: midPoint)
        drawLayer.path = beziPath.cgPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let currentPoint = touch?.location(in: self) else { return }
        guard let prePoint = touch?.previousLocation(in: self) else { return }
        let midPoint = midPoint(p1: prePoint, p2: currentPoint)
        beziPath.addQuadCurve(to: currentPoint, controlPoint: midPoint)
        beziPath.close()
        drawLayer.path = beziPath.cgPath
    }

    func selectedPath() -> UIBezierPath {
        beziPath!
    }

    func selectedRect() -> CGRect {
        beziPath.bounds
    }
}
