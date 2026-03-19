class_name BackgroundDataPrefetcher
extends Node

## Expert Content Delivery: Offloads asset pre-fetching to background threads.
## Ensures smooth level transitions on slow console storage.

func prefetch_assets(paths: Array[String]) -> void:
	for path in paths:
		# Use WorkerThreadPool to keep the main thread fluid
		WorkerThreadPool.add_task(_load_asset.bind(path))

func _load_asset(path: String) -> void:
	# ResourceLoader.load() on a background thread pre-fills the internal cache.
	# Subsequent calls to 'load()' on the main thread will be instant.
	var _res = ResourceLoader.load(path)
	print("Console: Prefetched ", path)

## Rule: Only prefetch non-critical assets (SFX, MeshData) to avoid I/O bottlenecks.
