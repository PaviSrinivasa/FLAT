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

import java.net.URI;
import java.util.UUID;
import nl.mpi.tla.flat.deposit.Context;
import nl.mpi.tla.flat.deposit.DepositException;
import nl.mpi.tla.flat.deposit.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author menzowi
 */
public class HandleAssignment extends AbstractAction {
    
    private static final Logger logger = LoggerFactory.getLogger(HandleAssignment.class.getName());

    @Override
    public boolean perform(Context context) throws DepositException {
        try {
            for (Resource res:context.getSIP().getResources()) {
                URI uri = res.getURI();
                if (uri.toString().startsWith("hdl:"+getParameter("prefix","foo")+"/") || uri.toString().startsWith("http://hdl.handle.net/"+getParameter("prefix","foo")+"/")) {
                    // keep the PID
                    res.setPID(res.getURI());
                    logger.info("Retained PID["+res.getPID()+"]");

                } else {
                    res.setPID(new URI("hdl:"+getParameter("prefix","foo")+"/"+UUID.randomUUID()));
                    logger.info("Assigned PID["+res.getPID()+"] to Resource["+res.getURI()+"]");
                }
            }
            context.getSIP().save();
        } catch (Exception ex) {
            throw new DepositException("Couldn't assign PIDs!",ex);
        }
        return true;
    }
    
}
