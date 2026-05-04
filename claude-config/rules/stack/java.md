# Java / Spring Boot Stack Overlay

> Comentario en español: reglas Java/Spring sobre lo común. Aplica cuando el proyecto detectado
> usa Java (con o sin Spring).

## Version

- Java 21 LTS minimum (records, pattern matching, virtual threads).
- Maven OR Gradle — pick one per project.

## Modern Java idioms

- `record` for DTOs/value objects, NOT POJOs with boilerplate.
- `sealed` interfaces + records for ADT-like patterns.
- Pattern matching for instanceof and switch.
- `var` for local variables when type is obvious.
- `Optional<T>` ONLY for return values, NEVER for fields or params.
- Streams + collectors over loops where readable.

## Spring Boot conventions

- Layered: Controller → Service → Repository.
- `@RestController` (NOT `@Controller` + `@ResponseBody`).
- Constructor injection ONLY (no `@Autowired` field injection).
- `@Transactional` at service layer, NOT controller.
- `application.yml` (NOT `.properties`).
- Profiles: `dev`, `test`, `prod`.

## JPA / Hibernate

- Lazy loading by default; `@EntityGraph` or fetch joins for N+1.
- DTOs at API boundary, NEVER expose entities directly.
- `@Version` for optimistic locking on mutable entities.
- Migrations via Flyway or Liquibase, NEVER `hibernate.hbm2ddl.auto=update` in prod.

## Testing

- JUnit 5 (Jupiter), NOT JUnit 4.
- AssertJ for assertions (`assertThat(x).isEqualTo(y)`).
- Mockito for mocks; `@MockBean` only when needed.
- Testcontainers for DB integration tests.
- `@WebMvcTest` for controller slice tests.
- `@DataJpaTest` for repository tests.

## Tooling defaults

- Formatter: Spotless (with google-java-format).
- SpotBugs + PMD + Checkstyle in CI.
- JaCoCo for coverage.
- OWASP dependency-check.

## Security

- Spring Security with `@PreAuthorize` annotations.
- BCrypt for passwords (`PasswordEncoder`).
- JWT with HS256/RS256, NEVER none.
- CSRF enabled by default for stateful sessions.

## Common pitfalls to avoid

- Field injection (`@Autowired` on fields) → constructor.
- `findById().get()` → handle Optional properly.
- Returning entities from REST → use DTOs.
- Exposing internal IDs → use UUIDs or external IDs.
- Loading collections eagerly → fetch strategies.
