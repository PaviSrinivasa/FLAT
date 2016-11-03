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
package nl.mpi.tla.flat.deposit.action;

import java.io.InputStream;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Scanner;
import nl.mpi.tla.flat.deposit.Context;
import nl.mpi.tla.flat.deposit.DepositException;
import nl.mpi.tla.flat.deposit.sip.Resource;
import nl.mpi.tla.flat.deposit.sip.SIPInterface;

/**
 *
 * @author menzowi
 */
public class Index extends AbstractAction {
    
    @Override
    public boolean perform(Context context) throws DepositException {
        
        String gsearchService = getParameter("gsearchServer");
        if (!gsearchService.endsWith("/")) {
            gsearchService += "/";
        }
        final String gsearchUser = getParameter("gsearchUser");
        final String gsearchPass = getParameter("gsearchPassword");
        
        SIPInterface sip = context.getSIP();

        try {
            URL gsearchEndpoint = new URL(gsearchService);
            
            Authenticator.setDefault (new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication (gsearchUser, gsearchPass.toCharArray());
                }
            });
            
            URL call = new URL(gsearchEndpoint,"rest?operation=updateIndex&action=fromPid&value="+URLEncoder.encode(sip.getFID().toString().replaceAll("#.*",""), "UTF-8"));

            InputStream response = call.openStream();
            try (Scanner scanner = new Scanner(response)) {
                String responseBody = scanner.useDelimiter("\\A").next();
                //System.err.println(responseBody);
            }
            
            for (Resource res:sip.getResources()) {
                call = new URL(gsearchEndpoint,"rest?operation=updateIndex&action=fromPid&value="+URLEncoder.encode(res.getFID().toString().replaceAll("#.*",""), "UTF-8"));

                response = call.openStream();
                try (Scanner scanner = new Scanner(response)) {
                    String responseBody = scanner.useDelimiter("\\A").next();
                    //System.err.println(responseBody);
                }
            }
        } catch (Exception ex) {
            throw new DepositException(ex);
        }
        
        return true;
    }
    
}
