import Foundation
import CoreGraphics

let DefinedScreenWidth: CGFloat = 1536
let DefinedScreenHeight: CGFloat = 2048

enum GameSceneChildName: String {
    case BridgeName = "bridge"
    case IslandMidName = "island_mid"
    case ScoreName = "score"
    case TipName = "tip"
    case PerfectName = "perfect"
    case GameOverLayerName = "over"
    case RetryButtonName = "retry"
    case HighScoreName = "highscore"
}

enum GameSceneActionKey: String {
    case WalkAction = "walk"
    case BridgeGrowAudioAction = "bridge_grow_audio"
    case BridgeGrowAction = "bridge_grow"
    case HeroScaleAction = "hero_scale"
}

enum GameSceneEffectAudioName: String {
    case DeadAudioName = "dead.wav"
    case BridgeGrowAudioName = "grow_loop.wav"
    case BridgeGrowOverAudioName = "kick.wav"
    case BridgeFallAudioName = "fall.wav"
    case BridgeTouchMidAudioName = "touch_mid.wav"
    case VictoryAudioName = "victory.wav"
    case HighScoreAudioName = "highScore.wav"
}

enum GameSceneZposition: CGFloat {
    case BackgroundZposition = 0
    case IslandMidZposition = 35
    case BridgeZposition = 40
    case ScoreBackgroundZposition = 50
    case ScoreZposition, TipZposition, PerfectZposition = 100
    case GameOverZposition
}
