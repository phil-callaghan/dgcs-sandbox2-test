package dgcs.sandbox.tenant.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonPropertyOrder({
    "instanceId",
    "region",
    "availabilityZone",
    "version"
})
public class Metadata {
    @JsonProperty("availability-zone")
    private String availabilityZone;

    private String instanceId;

    private String region;

    private String version;
}
