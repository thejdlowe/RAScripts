// Bomb Jack
// #ID = 12011

// $0000: This MAY be the variable that tracks the state of the game; 3 = movable, 4 = cannot control
// $0013: Dip Switch 1 during gameplay
//        
//        Default dipswitch value = 192 Dec
// $0014: Dip Switch 2 during gameplay
//        
//        Default dipswitch value = 80 Dec
// $0026: Is this game two player?
//        
//        0 = 1 player
//        1 = 2 player
// $0027: Indicator of which player is playing (0 = Player 1, 1 = Player 2)
// $0036: Timer for when you collect the Power Up; is 0 constantly until the power up is activated
// $0070: This is a flag for if we are currently in a game. 1 = playable, 0 = nonplayable
//        
//        HOWEVER, if it's a two player game, and one player dies far before the other, it still stays marked as playable and does not change to game over.
// $0090: How many coins have been entered! (BDC)
// $019B: Current Lives for Player 1 (tied to 0x01b4); this is a signed byte, so if this value goes above 128 and you die, it's immediate game over
// $019C: 00,000,0xx of player 1 score (BCD)
// $019D: 00,00x,x00 of player 1 score (BCD)
// $019E: 00,xx0,000 of player 1 score (BCD)
// $019F: xx,000,000 of player 1 score (BCD)
// $01A0: Current map being displayed for Player 1
// $01A2: How many bombs are still on the screen for Player 1 (Hex)
// $01A7: If this is set to hex 14, a P ball will ALWAYS be on screen
// $01AB: How many Lit Bombs collected on the current screen for player 1, counting up; maximum is 0x17 (Hex)
// $01AC: Current Bonus Multiplier for Player 1 (maxes out at 4 in game; increasing this does actually increase the multiplier itself!)
// $01AF: What the round number displays at the bottom for Player 1
// $024A: If this is locked at hex value 1e, player 1 is invulnerable
// $045F: What determines the color of the P-Coin!
//        
//        1 = Blue
//        2 = Red
//        3 = Pink
//        4 = Green
//        5 = Aqua Blue
//        6 = Gold
//        7 = Gray
// $0484: During initial check of dipswitches during startup, this stores Dip Switch 1
// $0485: During initial check of dipswitches during startup, this stores Dip Switch 2

function GameState() => byte(0x0070)

DemoMode = 0x00
InGameMode = 0x01

function PlayerControl() => byte(0x0000)

AcceptJoystickInput = 0x03
IgnoreJoystickInput = 0x04

function DefaultDipswitchCheck() => byte(0x0013) == 192 && byte(0x0014) == 80

function IsSinglePlayer() => byte(0x0026) == 0

CurrentLifeCount = byte(0x019B)

CurrentLevel = byte(0x01AF)

CurrentPowerTimer = byte(0x0036)
CurrentPowerLevel = byte(0x045F)

CurrentMultiplier = byte(0x01AC)

function IsUsingDefaultSettings() {
    start = once(GameState() == DemoMode)
    cancel = never(GameState() == InGameMode && !IsSinglePlayer())

    return start && cancel && trigger_when(DefaultDipswitchCheck() && IsSinglePlayer() && GameState() == InGameMode)
}

function GrabbedPowerUp() {
    return CurrentPowerTimer != 0 && prev(CurrentPowerTimer) == 0
}

function GameOver() => GameState() == InGameMode && CurrentLifeCount > 127

BombsLeft = byte(0x01A2)
LitBombsCollected = byte(0x01AB)

function ScoreX0000000() => high4(0x019F)
function Score0X000000() => low4(0x019F)
function Score00X00000() => high4(0x019E)
function Score000X0000() => low4(0x019E)
function Score0000X000() => high4(0x019D)
function Score00000X00() => low4(0x019D)
function Score000000X0() => high4(0x019C)
function Score0000000X() => low4(0x019C)

function Score() {
    return (
          ScoreX0000000() * 10000000
        + Score0X000000() * 1000000
        + Score00X00000() * 100000
        + Score000X0000() * 10000
        + Score0000X000() * 1000
        + Score00000X00() * 100
        + Score000000X0() * 10
        + Score0000000X()
    )
}

//FIREBOMB ACHIEVEMENTS
achievement(
    title = "These Are Some Spicy Cinnamon Balls!",
    description = "Collect 20 Fire Bombs in one stage",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && LitBombsCollected >= 20,
    points = 0
)

achievement(
    title = "They Really Pack Some Heat!",
    description = "Collect 21 Fire Bombs in one stage",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && LitBombsCollected >= 21,
    points = 0
)

achievement(
    title = "But They Do Taste Funny...",
    description = "Collect 22 Fire Bombs in one stage",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && LitBombsCollected >= 22,
    points = 0
)

achievement(
    title = "I Have Just Been Informed These Are Not Cinnamon Balls",
    description = "Collect 23 Fire Bombs in one stage",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && LitBombsCollected >= 23,
    points = 0
)

//MULTIPLIER ACHIEVEMENTS
achievement(
    title = "Multiplier? I Hardly Know 'Er!",
    description = "Get your multiplier to 2x",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && CurrentMultiplier == 1,
    points = 0
)

achievement(
    title = "Multiplier? I Hardly Know 'Er! 2",
    description = "Get your multiplier to 5x",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && CurrentMultiplier == 4,
    points = 0
)

//POWERUP ACHIEVEMENTS
achievement(
    title = "Platinum Power Up",
    description = "Grab the Power Up Coin when it is gray to get the most points out of it",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && GrabbedPowerUp() && CurrentPowerLevel == 0 && prev(CurrentPowerLevel) == 7,
    points = 0
)

achievement(
    title = "Platinum Power Up To The Max",
    description = "Get your multiplier to 5x and grab the Power Up Coin when it is gray",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && CurrentMultiplier == 4 && GrabbedPowerUp() && CurrentPowerLevel == 0 && prev(CurrentPowerLevel) == 7,
    points = 0
)

//LEVEL ACHIEVEMENTS
achievement(
    title = "Did They Build The Pyramids From The Top Down?",
    description = "Complete Round 1 (Egypt)",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && CurrentLevel == 1 && LitBombsCollected != 0,
    points = 0
)

achievement(
    title = "Rome If You Want To; Rome Around The World",
    description = "Complete Round 2 (Rome)",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && CurrentLevel == 2 && LitBombsCollected != 0,
    points = 0
)

achievement(
    title = "Now's The Time In Bombjack When We Dance",
    description = "Complete Round 3 (Germany)",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && CurrentLevel == 3 && LitBombsCollected != 0,
    points = 0
)

achievement(
    title = "You Know, They Say This Stage, It's Like Its Own Character",
    description = "Complete Round 4 (New York)",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && CurrentLevel == 4 && LitBombsCollected != 0,
    points = 0
)

achievement(
    title = "Around The World In 5 Stages",
    description = "Complete Round 5 (California)",
    trigger = IsUsingDefaultSettings() && IsSinglePlayer() && BombsLeft == 0 && CurrentLevel == 5 && LitBombsCollected != 0,
    points = 0
)


//FUNCTIONALITY ACHIEVEMENTS
achievement(
    title = "Default Settings Check",
    description = "Coin A 1 Coin 1 Credit, Coin B 1 Coin 1 Credit, Single Player Mode, 3 Lives, Cabinet Upright, Demo Sounds On, No Bonus Life, Bird Speed Hard, Enemies Number Speed Hard, Special Coin Easy",
    trigger = IsUsingDefaultSettings(),
    points = 0
)

//achievement(
//    title = "Game Over",
//    description = "Single Player Mode, 3 Lives, No Bonus Life, Bird Speed Hard, Enemies Number Speed Hard, Special Coin Easy",
//    trigger = GameOver(),
//    points = 0
//)

//RICH PRESENCE
rich_presence_conditional_display(!DefaultDipswitchCheck(), "Playing casually with non-default settings")
rich_presence_display("Score: {0} | L={1} | {2} Lives",
    rich_presence_macro("Number", Score()),
    rich_presence_macro("Number", CurrentLevel),
    rich_presence_macro("Number", CurrentLifeCount)
)

//LEADERBOARD
leaderboard(
    "High Score",
    "High score on default settings (3 lives, No bonus lives via points, Bird Speed Hard, Enemies Number Speed Hard, Special Coin Easy)",
    DefaultDipswitchCheck() && GameState() == InGameMode && IsSinglePlayer(),
    always_false(),
    GameOver(),
    Score()
)