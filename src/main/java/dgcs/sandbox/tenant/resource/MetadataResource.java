package dgcs.sandbox.tenant.resource;

import dgcs.sandbox.tenant.manager.MetadataManager;
import dgcs.sandbox.tenant.model.Metadata;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class MetadataResource {
    @RequestMapping(value = "/", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    public ResponseEntity<Metadata> getMetadata() {
        return ResponseEntity.ok(
            MetadataManager.getMetadata()
        );
    }
}
