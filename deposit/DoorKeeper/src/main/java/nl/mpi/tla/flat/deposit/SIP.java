/*
 * Copyright (C) 2015 menzowi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.mpi.tla.flat.deposit;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.attribute.FileTime;
import java.text.SimpleDateFormat;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import javax.xml.transform.dom.DOMSource;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmNode;
import nl.mpi.tla.flat.deposit.util.Saxon;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 *
 * @author menzowi
 */
public class SIP {
    
    private static final Logger logger = LoggerFactory.getLogger(SIP.class.getName());
    
    public static String CMD_NS = "http://www.clarin.eu/cmd/";
    public static String LAT_NS = "http://lat.mpi.nl/";
    
    protected File base = null;
    protected URI pid = null;

    protected Document rec = null;
    
    protected Set<Resource> resources = new LinkedHashSet();
    
    protected Map<String,String> namespaces = new LinkedHashMap<>();
    
    public SIP(File spec) throws DepositException {
        this.base = spec;
        load(spec);
        loadResourceList();
    }
    
    public File getBase() {
        return this.base;
    }
    
    public Document getRecord() {
        return this.rec;
    }
    
    // PID
    public boolean hasPID() {
        return (this.pid != null);
    }
    
    public void setPID(URI pid) throws DepositException {
        if (this.pid!=null)
            throw new DepositException("SIP["+this.base+"] has already a PID!");
        if (pid.toString().startsWith("hdl:")) {
            this.pid = pid;
        } else if (pid.toString().startsWith("http://hdl.handle.net/")) {
            try {
                this.pid = new URI(pid.toString().replace("http://hdl.handle.net/", "hdl:"));
            } catch (URISyntaxException ex) {
                throw new DepositException(ex);
            }
        } else {
            throw new DepositException("The URI["+pid+"] isn't a valid PID!");
        }
    }
    
    public URI getPID() throws DepositException {
        if (this.pid==null)
            throw new DepositException("SIP["+this.base+"] has no PID yet!");
        return this.pid;
    }
       
    // resources
    
    private void loadResourceList() throws DepositException {
        try {
            for (XdmItem resource:Saxon.xpath(Saxon.wrapNode(this.rec),"/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType='Resource']",null,getNamespaces())) {
                Node resNode = Saxon.unwrapNode((XdmNode)resource);
                Resource res = new Resource(base.toURI().resolve(Saxon.xpath2string(resource,"cmd:ResourceRef",null,getNamespaces())),resNode);
                if (Saxon.xpath2boolean(resource,"normalize-space(cmd:ResourceType/@mimetype)!=''",null,getNamespaces())) {
                    res.setMime(Saxon.xpath2string(resource,"cmd:ResourceType/@mimetype"));
                }
                if (Saxon.xpath2boolean(resource,"normalize-space(cmd:ResourceRef/@lat:localURI)!=''",null,getNamespaces())) {
                    File resFile = new File(base.toPath().getParent().normalize().toString(),Saxon.xpath2string(resource,"cmd:ResourceRef/@lat:localURI",null,getNamespaces()));
                    if (resFile.exists()) {
                        if (resFile.canRead()) {
                            res.setFile(resFile);
                        } else
                            logger.warn("local file for ResourceProxy["+Saxon.xpath2string(resource,"cmd:ResourceRef",null,getNamespaces())+"]["+resFile.getPath()+"] isn't readable!");
                    } else
                        logger.warn("local file for ResourceProxy["+Saxon.xpath2string(resource,"cmd:ResourceRef",null,getNamespaces())+"]["+resFile.getPath()+"] doesn't exist!");
                }
                if (resources.contains(res)) {
                    logger.warn("double ResourceProxy["+Saxon.xpath2string(resource,"cmd:ResourceRef",null,getNamespaces())+"]["+res.getURI()+"]!");
                } else {
                    resources.add(res);
                    logger.debug("ResourceProxy["+Saxon.xpath2string(resource,"cmd:ResourceRef",null,getNamespaces())+"]["+res.getURI()+"]");
                }
            }
        } catch(SaxonApiException e) {
            throw new DepositException(e);
        }
    }
    
    public Set<Resource> getResources() {
        return this.resources;
    }
    
    public void saveResourceList() throws DepositException {
        try {
            for (Resource res:getResources()) {
                Node node = res.getNode();
                if (res.hasMime()) {
                    Element rt = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(node), "cmd:ResourceType", null, getNamespaces()));
                    rt.setAttribute("mimetype", res.getMime());
                }
                if (res.hasFile()) {
                    Element rr = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(node), "cmd:ResourceRef", null, getNamespaces()));
                    rr.setAttributeNS(LAT_NS,"lat:localURI",base.getParentFile().toPath().normalize().relativize(res.getFile().toPath().normalize()).toString());
                }
                if (res.hasPID()) {
                    Element rr = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(node), "cmd:ResourceRef", null, getNamespaces()));
                    rr.setTextContent(res.getPID().toString());
                }
            }                    
        } catch(Exception e) {
            throw new DepositException(e);
        }
    }
    
    // IO
    
    public void load(File spec) throws DepositException {
        try {
            this.rec = Saxon.buildDOM(spec);
            String self = Saxon.xpath2string(Saxon.wrapNode(this.rec), "/cmd:CMD/cmd:Header/cmd:MdSelfLink", null, this.getNamespaces());
            if (!self.trim().equals("")) {
                try {
                    this.setPID(new URI(self));
                } catch(DepositException e) {
                    logger.warn("current selfLink["+self+"] isn't a valid PID, ignored for now!");
                }
            }
        } catch(Exception e) {
            throw new DepositException(e);
        }
    }
    
    public void save() throws DepositException {
        try {
            if (base.exists()) {
                // always keep the org around
                File org = new File(base.toString()+".org");
                if (!org.exists())
                    Files.copy(base.toPath(),org.toPath());
                // and keep timestamped backups
                FileTime stamp = Files.getLastModifiedTime(base.toPath());
                SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd-HHmmss");
                String ext = df.format(stamp.toMillis());
                int i = 0;
                File bak = new File(base.toString()+"."+ext);
                while (bak.exists())
                    bak = new File(base.toString()+"."+ext+"."+(++i));
                Files.move(base.toPath(),bak.toPath());
            }
            // put PID into place
            if (this.hasPID()) {
                if (Saxon.xpath2boolean(Saxon.wrapNode(this.rec), "exists(/cmd:CMD/cmd:Header/cmd:MdSelfLink)", null, this.getNamespaces())) {
                    Element self = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(this.rec), "/cmd:CMD/cmd:Header/cmd:MdSelfLink", null, getNamespaces()));
                    self.setTextContent(this.getPID().toString());
                } else {
                    Element profile = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(this.rec), "/cmd:CMD/cmd:Header/cmd:MdProfile", null, getNamespaces()));
                    Element header = (Element)Saxon.unwrapNode((XdmNode)Saxon.xpath(Saxon.wrapNode(this.rec), "/cmd:CMD/cmd:Header", null, getNamespaces()));
                    Element self = rec.createElementNS(CMD_NS, "MdSelfLink");
                    self.setTextContent(this.getPID().toString());
                    header.insertBefore(self, profile);
                }
            }   
            // save changes to the resource list
            saveResourceList();
            DOMSource source = new DOMSource(rec);
            Saxon.save(source,base);
        } catch(Exception e) {
            throw new DepositException(e);
        }
    }
    
    // utils
        
    public Map<String,String> getNamespaces() {
        if (this.namespaces.size()==0) {
            namespaces.put("cmd", CMD_NS);
            namespaces.put("lat", LAT_NS);
        }
        return this.namespaces;
    }
    
}
