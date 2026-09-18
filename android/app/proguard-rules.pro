# Rules for R8, the release-build shrinker, beyond the ones Flutter and each
# library already ship. Debug builds don't run R8, so a mistake here only shows
# in a release build: launch one on a device before merging a new dependency.

# Room finds each database's generated implementation by reflection, so R8
# sees nothing ever constructing it. In full mode (the default since AGP 8)
# it then makes the class abstract, and the app dies at launch with
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
# WorkManager arrived with the ads SDK in 1.12.0, and that release crashed
# on launch because of this. Keep every Room database's no-argument
# constructor, which also stops R8 treating the class as never created.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
