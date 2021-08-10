settings "settings.opy.json"

#Player variables

playervar score 1

#Global variables
globalvar inProgress 1

rule "Setup - Global":
    @Event global
    @Condition isAssemblingHeroes() == true

    setMatchTime(1)
    disableAnnouncer()
    disableGamemodeCompletion()
    disableMusic()
    
    inProgress = false

rule "Setup - Player Joins":
    @Event playerJoined
    
    eventPlayer.score = 0
    eventPlayer.setRespawnTime(9999)
    eventPlayer.setKnockbackReceived(0)
    eventPlayer.enableDeathSpectateAllPlayers()

    #Kill player if join during round.
    if inProgress:
        kill(eventPlayer, null)

def startRoundSub():
    inProgress = true
    getAllPlayers().setKnockbackDealt(100)
    getAllPlayers().setKnockbackReceived(100)

def endRoundSub():
    inProgress = false
    getDeadPlayers(Team.ALL).respawn()
    getAllPlayers().setKnockbackDealt(0)
    getAllPlayers().setKnockbackReceived(0)


rule "Player Dies":
    @Event playerDied
    
    eventPlayer.setScore(eventPlayer.score)

rule "Player Wins":
    @Event eachPlayer
    @Condition inProgress == true
    @Condition getNumberOfLivingPlayers(Team.ALL) == 1
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.score += 1
    eventPlayer.setScore(eventPlayer.score)
    endRoundSub()
    
rule "All Players Dead":
    @Event global
    @Condition getNumberOfLivingPlayers(Team.ALL) == 0

    endRoundSub()

rule "Quick Respawn Between Rounds":
    @Event eachPlayer
    @Condition inProgress == false
    @Condition eventPlayer.isDead()

    eventPlayer.respawn()

rule "Start Gamemode":
    @Event eachPlayer
    @Condition hostPlayer == eventPlayer
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    bigMessage(getAllPlayers(), "10 Seconds to get off the ground")
    wait(5)
    bigMessage(getAllPlayers(), "ready")
    wait(3)
    bigMessage(getAllPlayers(), "set")
    wait(4)
    bigMessage(getAllPlayers(), "GO!")
    wait(1)

    startRoundSub()

rule "Floor is Lava":
    @Event eachPlayer
    @Condition inProgress == true
    @Condition eventPlayer.isOnGround() == true
    
    kill(eventPlayer, null)

rule "Remove Stall Camping":
    @Event eachPlayer
    @Condition inProgress == true
    @Condition eventPlayer.getSpeed() < 0.08
    @Condition eventPlayer.isInAir() == true
    @Condition eventPlayer.isUsingAbility2() == false
    
    wait(1.49, Wait.ABORT_WHEN_FALSE)
    bigMessage(eventPlayer, "STOP CAMPING!")
    wait(1.49, Wait.ABORT_WHEN_FALSE)
    kill(eventPlayer, null)

rule "Rules HUD":
    @Event global
    hudText(localPlayer, "Rules", null, null, HudPosition.LEFT, 0, Color.RED, null, null, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer, "Host: Use {} to begin game.\nUse your doomfist parkour skills to stay off the ground.\nCamping in stalls is punishable by death.".format(Button.ULTIMATE), HudPosition.LEFT, 1, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)