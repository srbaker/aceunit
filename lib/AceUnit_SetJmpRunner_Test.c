#include <setjmp.h>
#include <stdlib.h>
#include <aceunit.h>

extern jmp_buf *AceUnit_env;

bool ran_test_failing = false;
bool ran_test_ok = false;

void test_failing(void) {
    ran_test_failing = true;
    assert(false);
}

void test_ok(void) {
    ran_test_ok = true;
}

int main(void) {
#if defined(__BCC__)
    AceUnit_Result_t result;
    result.testCaseCount = 0;
    result.successCount = 0;
    result.failureCount = 0;
#else
    AceUnit_Result_t result = { 0, 0, 0 };
#endif
    AceUnit_run(fixtures, &result);
#undef assert
#include <assert.h>
    assert(result.testCaseCount == 2);
    assert(result.successCount == 1);
    assert(result.failureCount == 1);
    assert(ran_test_failing);
    assert(ran_test_ok);
    return EXIT_SUCCESS;
}
