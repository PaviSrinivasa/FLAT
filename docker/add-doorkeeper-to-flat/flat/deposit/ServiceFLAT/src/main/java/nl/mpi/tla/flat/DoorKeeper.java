package nl.mpi.tla.flat;

import nl.mpi.tla.flat.deposit.Flow;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletContext;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmValue;

@Path("/doorkeeper/{sip}")
public class DoorKeeper {
    
    @Context
    private ServletContext servletContext;
    
    private Flow getFlow(Map<String,XdmValue> params) throws Exception {
        return new Flow(new File(servletContext.getInitParameter("doorkeeperConfig")),params);
    }

    @POST
    @Produces("text/plain")
    public Response postSip(@PathParam("sip") String sip) {
        Map<String,XdmValue> params = new HashMap();
        params.put("sip", new XdmAtomicValue(sip));
        String sipDir = "";
        try {
            sipDir = this.getFlow(params).getContext().getProperty("work", "/tmp").toString();
            File sd = new File(sipDir);
            if (!sd.isDirectory()) {
                return Response.status(Status.NOT_FOUND).entity("The SIP["+sip+"] doesn't exist!").type("text/plain").build();
            }
        } catch (Exception ex) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity(ex.getMessage()).type("text/plain").build();
        }        
        return Response.status(Status.CREATED).entity("sip directory["+sipDir+"]").type("text/plain").build();
    }

    @GET
    @Produces("text/plain")
    public Response getSip(@PathParam("sip") String sip) {
        return Response.status(Status.OK).entity("Got it!").type("text/plain").build();
    }
    
}
