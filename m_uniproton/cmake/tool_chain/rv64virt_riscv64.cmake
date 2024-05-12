set(OBJCOPY_PATH "$ENV{HCC_PATH}" )
##最终的链接目标，会生成对应的.a库
#################################################
## guest代码
#################################################
#添加进列表
foreach(FILE_NAME ${ALL_OBJECT_LIBRARYS})
	list(FIND exclude "${FILE_NAME}" is_include)
	if(${is_include} EQUAL -1)
	list(APPEND GUEST_SRCS
		$<TARGET_OBJECTS:${FILE_NAME}>
	)
	endif()
endforeach()

#编译结果
string(TOUPPER ${PLAM_TYPE} PLAM_TYPE_UP)
string(TOUPPER ${CPU_TYPE} CPU_TYPE_UP)
add_library(RV64VIRT  STATIC "${GUEST_SRCS}")
add_custom_target(cleanobj)
add_custom_command(TARGET cleanobj POST_BUILD
				COMMAND echo finishing)

if (${COMPILE_MODE} MATCHES "^.*dbg.*$")
	message("=============== COMPILE_MODE is ${COMPILE_MODE} ===============")
endif()

####以下为make install打包脚本#####
set(rv64virt_riscv64_export modules)

# 下面的变量分别定义了安装根目录、头文件安装目录、动态库安装目录、静态库安装目录、OBJECT文件安装目录、可执行程序安装目录、配置文件安装目录。
# 注意：所有安装路径必须是相对CMAKE_INSTALL_PREFIX的相对路径，不可以使用绝对路径!!!
# 否则安装目录下的配置文件(foo-config.cmake, foo-tragets.cmake等)拷贝到其它目录时无法工作。
set(INSTALL_RV64VIRT_RISCV64_BASE_DIR                 .)
set(INSTALL_RV64VIRT_RISCV64_INCLUDE_DIR              UniProton/include)
set(INSTALL_RV64VIRT_RISCV64_INCLUDE_SEC_DIR          libboundscheck/include)
set(INSTALL_RV64VIRT_RISCV64_ARCHIVE_DIR              UniProton/lib/rv64virt)
set(INSTALL_RV64VIRT_RISCV64_ARCHIVE_SEC_DIR          libboundscheck/lib/rv64virt)
set(INSTALL_RV64VIRT_RISCV64_ARCHIVE_CONFIG_DIR       UniProton/config)
set(INSTALL_RV64VIRT_RISCV64_CONFIG_DIR               cmake/rv64virt)


include(CMakePackageConfigHelpers)
configure_package_config_file(${PROJECT_SOURCE_DIR}/cmake/tool_chain/rv64virt_riscv64_config.cmake.in
	${CMAKE_CURRENT_BINARY_DIR}/uniproton-rv64virt-riscv64-config.cmake
	INSTALL_DESTINATION ${INSTALL_RV64VIRT_RISCV64_CONFIG_DIR}
	PATH_VARS
	INSTALL_RV64VIRT_RISCV64_BASE_DIR
	INSTALL_RV64VIRT_RISCV64_INCLUDE_DIR
	INSTALL_RV64VIRT_RISCV64_INCLUDE_SEC_DIR
	INSTALL_RV64VIRT_RISCV64_ARCHIVE_DIR
	INSTALL_RV64VIRT_RISCV64_ARCHIVE_SEC_DIR
	INSTALL_RV64VIRT_RISCV64_ARCHIVE_CONFIG_DIR
	INSTALL_RV64VIRT_RISCV64_CONFIG_DIR
	INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}
)
install(EXPORT ${rv64virt_riscv64_export}
		NAMESPACE UniProton::
		FILE uniproton-rv64virt-riscv64-targets.cmake
		DESTINATION ${INSTALL_RV64VIRT_RISCV64_CONFIG_DIR}
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/uniproton-rv64virt-riscv64-config.cmake
	DESTINATION ${INSTALL_RV64VIRT_RISCV64_CONFIG_DIR}
)

if (${COMPILE_OPTION} STREQUAL "coverity" OR ${COMPILE_OPTION} STREQUAL "fortify" OR ${COMPILE_OPTION} STREQUAL "UniProton")
    message("Don't Install Sec Lib In ${COMPILE_OPTION}")
else()
	
    if (NOT "${RPROTON_INSTALL_FILE_OPTION}" STREQUAL "SUPER_BUILD")
        ##{GLOB 所有文件 | GLOB_RECURSE 递归查找文件&文件夹}
        file(GLOB glob_sec_files  ${PROJECT_SOURCE_DIR}/platform/libboundscheck/include/*.h)
        install(FILES
            ${glob_sec_files}
            DESTINATION ${INSTALL_RV64VIRT_RISCV64_INCLUDE_SEC_DIR}
        )
    endif()
endif()


install(TARGETS
	RV64VIRT
	EXPORT ${rv64virt_riscv64_export}
	ARCHIVE DESTINATION ${INSTALL_RV64VIRT_RISCV64_ARCHIVE_DIR}/
)

set(TOOLCHAIN_DIR "$ENV{HCC_PATH}") #该路径应该是外部传入,指向编译工具路径
if (${COMPILE_MODE} MATCHES "^.*dbg.*$")
	message("=============== COMPILE_MODE is ${COMPILE_MODE} ===============")
else()

endif()

install(FILES
	${PROJECT_SOURCE_DIR}/build/uniproton_config/config_riscv64_rv64virt/prt_buildef.h
	DESTINATION ${INSTALL_RV64VIRT_RISCV64_ARCHIVE_CONFIG_DIR}/riscv64/rv64virt
)

if (NOT "${LIBCK_INSTALL_FILE_OPTION}" STREQUAL "SUPER_BUILD")
	##{GLOB 所有文件 | GLOB_RECURSE 递归查找文件&文件夹}
	install(FILES
		${PROJECT_SOURCE_DIR}/src/config/prt_config.c
		${PROJECT_SOURCE_DIR}/src/config/prt_config_internal.h
		${PROJECT_SOURCE_DIR}/src/config/config/prt_config.h
		DESTINATION ${INSTALL_RV64VIRT_RISCV64_ARCHIVE_CONFIG_DIR}
	)
	##{GLOB 所有文件 | GLOB_RECURSE 递归查找文件&文件夹}
	file(GLOB common_include_files  ${PROJECT_SOURCE_DIR}/src/include/uapi/*.h)
	install(FILES
		${common_include_files}
		DESTINATION ${INSTALL_RV64VIRT_RISCV64_INCLUDE_DIR}
	)

	##{GLOB 所有文件 | GLOB_RECURSE 递归查找文件&文件夹 =======}
	file(GLOB hw_board_include_files  ${PROJECT_SOURCE_DIR}/src/include/uapi/hw/riscv64/*)
	install(FILES
		${hw_board_include_files}
		DESTINATION ${INSTALL_RV64VIRT_RISCV64_INCLUDE_DIR}/hw/riscv64
	)

	

	install(FILES
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_errno.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_event.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_exc.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_hook.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_hwi.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_mem.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_module.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_queue.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_sem.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_sys.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_task.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_tick.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_timer.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_typedef.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_cpup.h
		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_err.h
#		${PROJECT_SOURCE_DIR}/src/include/uapi/prt_signal.h
		DESTINATION ${INSTALL_RV64VIRT_RISCV64_INCLUDE_DIR}/
	)
endif()
