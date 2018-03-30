REM Stop and start Veritas VSS provider, and Volume Shadow copy services

REM  Stopping Services
sc stop "VERITAS VSS Provider" REM Veritas VSS Provider Service
sc stop VSS                    REM Volume Shadow Copy Service