package dgcs.sandbox.tenant.manager;

import java.util.Arrays;

import dgcs.sandbox.tenant.conf.Application;
import dgcs.sandbox.tenant.model.Metadata;
import dgcs.sandbox.tenant.model.UserData;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.client.RestTemplate;

public class MetadataManager {
    private static Metadata metadata = null;

    public static Metadata getMetadata() {
        if (metadata == null) {
            /* The AWS metadata function returns text/plain rather than the correct content type of
             * application/json.  Thus, the following configuration will use the Json converter for
             * a content type of text/plain.
             */
            MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
            converter.setSupportedMediaTypes(Arrays.asList(MediaType.TEXT_PLAIN, MediaType.APPLICATION_JSON));

            RestTemplate fetchTemplate = new RestTemplate();
            fetchTemplate.getMessageConverters().add(converter);

            UserData userData = fetchTemplate.getForObject(
                "http://169.254.169.254/latest/dynamic/instance-identity/document",
                UserData.class
            );

            metadata = Metadata.builder()
                .availabilityZone(userData.getAvailabilityZone())
                .instanceId(userData.getInstanceId())
                .region(userData.getRegion())
                .version(getVersion())
                .build();
        }

        return metadata;
    }

    private static String getVersion() {
        String version = Application.class.getPackage().getImplementationVersion();
        if (version == null) {
            version = "UNKNOWN";
        }

        return version;
    }
}
