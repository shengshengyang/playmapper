package com.familymap.service;

import com.familymap.model.entity.Place;
import com.familymap.util.GeometryHelper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class RouteOptimizationService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    public List<Place> optimizeRoute(List<Place> places) {
        if (places == null || places.size() <= 2) {
            return places;
        }

        // 使用貪心算法 (Nearest Neighbor) + 2-opt 優化
        List<Place> route = nearestNeighbor(places);
        route = twoOptOptimize(route);

        log.info("Optimized route with {} places", route.size());
        return route;
    }

    private List<Place> nearestNeighbor(List<Place> places) {
        List<Place> remaining = new ArrayList<>(places);
        List<Place> route = new ArrayList<>();

        // 從第一個景點開始
        Place current = remaining.remove(0);
        route.add(current);

        while (!remaining.isEmpty()) {
            Place nearest = null;
            double minDistance = Double.MAX_VALUE;

            for (Place candidate : remaining) {
                double distance = calculateDistance(current, candidate);
                if (distance < minDistance) {
                    minDistance = distance;
                    nearest = candidate;
                }
            }

            if (nearest != null) {
                remaining.remove(nearest);
                route.add(nearest);
                current = nearest;
            }
        }

        return route;
    }

    private List<Place> twoOptOptimize(List<Place> route) {
        boolean improved = true;
        List<Place> bestRoute = new ArrayList<>(route);

        while (improved) {
            improved = false;
            for (int i = 0; i < bestRoute.size() - 1; i++) {
                for (int j = i + 1; j < bestRoute.size(); j++) {
                    List<Place> newRoute = twoOptSwap(bestRoute, i, j);
                    if (calculateTotalDistance(newRoute) < calculateTotalDistance(bestRoute)) {
                        bestRoute = newRoute;
                        improved = true;
                    }
                }
            }
        }

        return bestRoute;
    }

    private List<Place> twoOptSwap(List<Place> route, int i, int j) {
        List<Place> newRoute = new ArrayList<>();
        // 0 to i-1
        for (int k = 0; k < i; k++) {
            newRoute.add(route.get(k));
        }
        // i to j (reversed)
        for (int k = j; k >= i; k--) {
            newRoute.add(route.get(k));
        }
        // j+1 to end
        for (int k = j + 1; k < route.size(); k++) {
            newRoute.add(route.get(k));
        }
        return newRoute;
    }

    public double calculateDistance(Place from, Place to) {
        if (from.getLocation() == null || to.getLocation() == null) {
            return 0.0;
        }

        return haversineDistance(
            GeometryHelper.getLatitude(from.getLocation()), GeometryHelper.getLongitude(from.getLocation()),
            GeometryHelper.getLatitude(to.getLocation()), GeometryHelper.getLongitude(to.getLocation())
        );
    }

    private double haversineDistance(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }

    public double calculateTotalDistance(List<Place> route) {
        double totalDistance = 0;
        for (int i = 0; i < route.size() - 1; i++) {
            totalDistance += calculateDistance(route.get(i), route.get(i + 1));
        }
        return totalDistance;
    }

    public int estimateDrivingTimeMinutes(double distanceKm) {
        // 假設平均時速 50 km/h
        return (int) Math.ceil(distanceKm / 50.0 * 60);
    }

    public double[][] calculateDistanceMatrix(List<Place> places) {
        int n = places.size();
        double[][] matrix = new double[n][n];

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i == j) {
                    matrix[i][j] = 0;
                } else {
                    matrix[i][j] = calculateDistance(places.get(i), places.get(j));
                }
            }
        }

        return matrix;
    }
}
