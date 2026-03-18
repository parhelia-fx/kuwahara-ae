package dof

import "vendor/adb"

suites: adb.Suites

load_suites :: proc "contextless" (basic_suite: ^adb.SP_Basic_Suite) {
    suites.basic_suite = basic_suite
    basic_suite.acquire_suite("AEGP World Suite", 2, (^rawptr)(&suites.aegp_world_suite2))
    basic_suite.acquire_suite("PF Handle Suite", 2, (^rawptr)(&suites.handle_suite1))
    basic_suite.acquire_suite("PF World Suite", 2, (^rawptr)(&suites.world_suite2))
    basic_suite.acquire_suite("PF GPU Device Suite", 1, (^rawptr)(&suites.gpu_device_suite1))
}

release_suites :: proc "contextless" (basic_suite: ^adb.SP_Basic_Suite) {
    basic_suite.release_suite("AEGP World Suite", 2)
    basic_suite.release_suite("PF Handle Suite", 2)
    basic_suite.release_suite("PF World Suite", 2)
    basic_suite.release_suite("PF GPU Device Suite", 1)
}