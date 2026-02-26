package com.familymap.util;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;

public class GeometryHelper {

    private static final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    private GeometryHelper() {
        // Utility class
    }

    public static Point createPoint(double longitude, double latitude) {
        return geometryFactory.createPoint(new Coordinate(longitude, latitude));
    }

    public static double getLatitude(Point point) {
        return point != null ? point.getY() : 0;
    }

    public static double getLongitude(Point point) {
        return point != null ? point.getX() : 0;
    }
}
