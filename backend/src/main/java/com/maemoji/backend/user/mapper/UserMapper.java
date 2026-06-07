package com.maemoji.backend.user.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

    Long findIdByEmail(@Param("email") String email);

    void insertDevUser();
}
