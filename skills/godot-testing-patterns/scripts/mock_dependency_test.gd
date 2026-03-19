# mock_dependency_test.gd
# Using Mocks to isolate test subjects
extends GdUnitTestSuite

# EXPERT NOTE: Mocking allows you to test a class without 
# requiring its real dependencies (e.g. Database, Network).

func test_inventory_save():
	var mock_storage = mock(StorageProvider)
	var inventory = Inventory.new()
	inventory.storage = mock_storage
	
	inventory.save()
	
	verify(mock_storage).save_data(any_dictionary())
	inventory.free()
