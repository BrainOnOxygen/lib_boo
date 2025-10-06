class_name BooEventBus extends Node

#region Signals
signal game_start()
signal game_end()
signal game_saved(data_saved: Variant)
signal game_loaded(data_loaded: Variant)
signal game_data_deleted(data_deleted: Variant)
#endregion