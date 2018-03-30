REM Stop and start Veritas VSS provider, and Volume Shadow copy services

REM  Stopping Services
sc start "VERITAS VSS Provider" REM Veritas VSS Provider Service
sc start VSS                    REM Volume Shadow Copy Service