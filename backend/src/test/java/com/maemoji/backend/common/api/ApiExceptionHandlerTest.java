package com.maemoji.backend.common.api;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import org.springframework.http.HttpMethod;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ApiExceptionHandlerTest {
    private final MockMvc mvc = MockMvcBuilders.standaloneSetup(new InputController())
            .defaultRequest(get("/").accept(MediaType.APPLICATION_JSON))
            .setControllerAdvice(new ApiExceptionHandler()).build();

    @Test
    void malformedJsonAndWrongParameterTypesReturn400() throws Exception {
        mvc.perform(post("/input").contentType(MediaType.APPLICATION_JSON).content("{broken"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.success").value(false));
        mvc.perform(get("/input").param("id", "not-a-number"))
                .andExpect(status().isBadRequest());
        mvc.perform(get("/input")) .andExpect(status().isBadRequest());
    }

    @Test
    void methodAndMediaTypeErrorsKeepTheirStatus() throws Exception {
        mvc.perform(delete("/input")).andExpect(status().isMethodNotAllowed());
        mvc.perform(post("/input").contentType(MediaType.TEXT_PLAIN).content("bad"))
                .andExpect(status().isUnsupportedMediaType());
        mvc.perform(get("/missing-resource")).andExpect(status().isNotFound());
    }

    @Test
    void exceptionDetailsAreNotReturnedToClient() throws Exception {
        mvc.perform(get("/invalid")) .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("입력값을 다시 확인해주세요."));
    }

    @RestController
    static class InputController {
        @GetMapping("/input") public long read(@RequestParam long id) { return id; }
        @PostMapping("/input") public Input write(@RequestBody Input input) { return input; }
        @GetMapping("/invalid") public void invalid() { throw new IllegalArgumentException("private detail"); }
        @GetMapping("/missing-resource") public void missing() throws NoResourceFoundException {
            throw new NoResourceFoundException(HttpMethod.GET, "missing");
        }
    }
    record Input(long id) {}
}
