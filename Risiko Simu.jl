

@everywhere function SimulateBattle(ArmiesAttacker::Int64, ArmiesDefender::Int64)
  while ArmiesDefender > 0 && ArmiesAttacker > 0
    DiceAttacker = rand(1:6, min(3, ArmiesAttacker))
    DiceDefender = rand(1:6, min(2, ArmiesDefender))
    sort!(DiceAttacker, rev=true)
    sort!(DiceDefender, rev=true)
    if DiceAttacker[1] > DiceDefender[1]
      ArmiesDefender -= 1
    else
    ArmiesAttacker -= 1
    end
    if ArmiesDefender >1 && ArmiesAttacker>1
      if DiceAttacker[2] > DiceDefender[2]
        ArmiesDefender -=1
      else ArmiesAttacker -=1
    end
  end
  end
  (ArmiesAttacker, ArmiesDefender)
end


@everywhere function SimulateBattleFast(ArmiesAttacker::Int64, ArmiesDefender::Int64)
  while ArmiesDefender > 2 && ArmiesAttacker > 3
    a = rand()
    if a <= 0.372
      ArmiesDefender -= 2
    elseif a > 0.372 && a <= 0.707
      ArmiesDefender -= 1
      ArmiesAttacker -= 1
    else
      ArmiesAttacker -= 2
    end
  end

  while ArmiesDefender > 0 && ArmiesAttacker > 0
    DiceAttacker = rand(1:6, min(3, ArmiesAttacker))
    DiceDefender = rand(1:6, min(2, ArmiesDefender))
    sort!(DiceAttacker, rev=true)
    sort!(DiceDefender, rev=true)
    if DiceAttacker[1] > DiceDefender[1]
      ArmiesDefender -= 1
    else
      ArmiesAttacker -= 1
    end
    if ArmiesDefender > 1 && ArmiesAttacker > 1
      if DiceAttacker[2] > DiceDefender[2]
        ArmiesDefender -= 1
      else ArmiesAttacker -= 1
    end
  end
  end
  (ArmiesAttacker, ArmiesDefender)
end

function SimulateRiskio(ArmiesAttacker, ArmiesDefender, NSim::Int64)
  result = Array{Float32}(length(ArmiesAttacker)
                          , length(ArmiesDefender))
    for (k, AA) in enumerate(ArmiesAttacker)
      for (j, AD) in enumerate(ArmiesDefender)
       battles = SharedArray(Int64,NSim,3)
        @sync @parallel for i in 1:NSim
           b = SimulateBattleFast(AA,AD)
           battles[i,1] = b[1]
           battles[i,2] = b[2]
        end
      AttackerWins = battles[:,1] .> battles[:,2]
      result[k,j] = mean(AttackerWins)
    end
  end
  result
end




d = @time SimulateRiskio(1:30,1:30,10000)


Pkg.add("Gadfly")

using Gadfly
using Colors
using Compose

draw(SVG("d:/probs.svg",15cm, 15cm),spy(d))

spy(d)
